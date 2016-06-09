require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "index" do

  let(:migration) { ::ActiveRecord::Migration }
  let(:connection) { ::ActiveRecord::Base.connection }

  describe "add_index" do

    before(:each) do
      connection.tables.each do |table| connection.drop_table table, cascade: true end

      define_schema(:auto_create => false) do
        create_table :users, :force => true do |t|
          t.string :login
          t.text :address
          t.datetime :deleted_at
        end

        create_table :posts, :force => true do |t|
          t.text :body
          t.integer :user_id
          t.integer :author_id
        end

        create_table :comments, :force => true do |t|
          t.text :body
          t.integer :post_id
          t.foreign_key :post_id, :posts, :id
        end
      end
      class User < ::ActiveRecord::Base ; end
      class Post < ::ActiveRecord::Base ; end
      class Comment < ::ActiveRecord::Base ; end
    end


    after(:each) do
      migration.suppress_messages do
        migration.remove_index(:users, :name => @index.name) if (@index ||= nil)
      end
    end

    it "should create index when called without additional options" do
      add_index(:users, :login)
      expect(index_for(:login)).not_to be_nil
    end

    it "should create unique index" do
      add_index(:users, :login, :unique => true)
      expect(index_for(:login).unique).to eq(true)
    end

    it "should assign given name" do
      add_index(:users, :login, :name => 'users_login_index')
      expect(index_for(:login).name).to eq('users_login_index')
    end

    it "should assign order", :mysql => :skip do
      add_index(:users, [:login, :deleted_at], :order => {:login => :desc, :deleted_at => :asc})
      expect(index_for([:login, :deleted_at]).orders).to eq({"login" => :desc, "deleted_at" => :asc})
    end

    it "should respect algorithm: :concurrently", :postgresql => :only do
      expect(connection).to receive(:execute).with(/CREATE INDEX CONCURRENTLY/)
      add_index(:users, :login, :algorithm => :concurrently)
    end if ActiveRecord::VERSION::MAJOR > 3

    context "for duplicate index" do
      it "should not complain if the index is the same" do
        add_index(:users, :login)
        expect(index_for(:login)).not_to be_nil
        expect(ActiveRecord::Base.logger).to receive(:warn).with(/login.*Skipping/)
        expect { add_index(:users, :login) }.to_not raise_error
        expect(index_for(:login)).not_to be_nil
      end
      it "should complain if the index is different" do
        add_index(:users, :login, :unique => true)
        expect(index_for(:login)).not_to be_nil
        expect { add_index(:users, :login) }.to raise_error
        expect(index_for(:login)).not_to be_nil
      end
    end

    context "extra features", :postgresql => :only do

      it "should assign conditions" do
        add_index(:users, :login, :conditions => 'deleted_at IS NULL')
        expect(index_for(:login).conditions).to eq('(deleted_at IS NULL)')
      end

      it "should assign expression, conditions and kind" do
        add_index(:users, :expression => "USING hash (upper(login)) WHERE deleted_at IS NULL", :name => 'users_login_index')
        @index = User.indexes.detect { |i| i.expression.present? }
        expect(@index.expression).to eq("upper((login)::text)")
        expect(@index.conditions).to eq("(deleted_at IS NULL)")
        expect(@index.kind).to       eq("hash")
      end

      it "should allow to specify expression, conditions and kind separately" do
        add_index(:users, :kind => "hash", :expression => "upper(login)", :conditions => "deleted_at IS NULL", :name => 'users_login_index')
        @index = User.indexes.detect { |i| i.expression.present? }
        expect(@index.expression).to eq("upper((login)::text)")
        expect(@index.conditions).to eq("(deleted_at IS NULL)")
        expect(@index.kind).to       eq("hash")
      end

      it "should allow to specify kind" do
        add_index(:users, :login, :kind => "hash")
        expect(index_for(:login).kind).to eq('hash')
      end

      it "should assign operator_class" do
        add_index(:users, :login, :operator_class => 'varchar_pattern_ops')
        expect(index_for(:login).operator_classes).to eq({"login" => 'varchar_pattern_ops'})
      end

      it "should assign multiple operator_classes" do
        add_index(:users, [:login, :address], :operator_class => {:login => 'varchar_pattern_ops', :address => 'text_pattern_ops'})
        expect(index_for([:login, :address]).operator_classes).to eq({"login" => 'varchar_pattern_ops', "address" => 'text_pattern_ops'})
      end

      it "should allow to specify actual expression only" do
        add_index(:users, :expression => "upper(login)", :name => 'users_login_index')
        @index = User.indexes.detect { |i| i.name == 'users_login_index' }
        expect(@index.expression).to eq("upper((login)::text)")
      end

      it "should raise if no column given and expression is missing" do
        expect { add_index(:users, :name => 'users_login_index') }.to raise_error(ArgumentError, /expression/)
      end

      it "should raise if expression without name is given" do
        expect { add_index(:users, :expression => "USING btree (login)") }.to raise_error(ArgumentError, /name/)
      end

      it "should raise if expression is given and case_sensitive is false" do
        expect { add_index(:users, :name => 'users_login_index', :expression => "USING btree (login)", :case_sensitive => false) }.to raise_error(ArgumentError, /use LOWER/i)
      end

    end

    protected

    def index_for(column_names)
      @index = User.indexes.detect { |i| i.columns == Array(column_names).collect(&:to_s) }
    end

  end

  describe "remove_index" do

    before(:each) do
      connection.tables.each do |table| connection.drop_table table, cascade: true end
      define_schema(:auto_create => false) do
        create_table :users, :force => true do |t|
          t.string :login
          t.datetime :deleted_at
        end
      end
      class User < ::ActiveRecord::Base ; end
    end


    it "removes index by column name (symbols)" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, :login
      expect(User.indexes.length).to eq(0)
    end

    it "removes index by column name (symbols)" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index 'users', 'login'
      expect(User.indexes.length).to eq(0)
    end

    it "removes multi-column index by column names (symbols)" do
      add_index :users, [:login, :deleted_at]
      expect(User.indexes.length).to eq(1)
      remove_index :users, [:login, :deleted_at]
      expect(User.indexes.length).to eq(0)
    end

    it "removes multi-column index by column names (strings)" do
      add_index 'users', [:login, :deleted_at]
      expect(User.indexes.length).to eq(1)
      remove_index 'users', ['login', 'deleted_at']
      expect(User.indexes.length).to eq(0)
    end

    it "removes index using column option" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, column: :login
      expect(User.indexes.length).to eq(0)
    end

    it "removes index if_exists" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, :login, :if_exists => true
      expect(User.indexes.length).to eq(0)
    end

    it "removes multi-column index if exists" do
      add_index :users, [:login, :deleted_at]
      expect(User.indexes.length).to eq(1)
      remove_index :users, [:login, :deleted_at], :if_exists => true
      expect(User.indexes.length).to eq(0)
    end

    it "removes index if_exists using column option" do
      add_index :users, :login
      expect(User.indexes.length).to eq(1)
      remove_index :users, column: :login, :if_exists => true
      expect(User.indexes.length).to eq(0)
    end

    it "raises exception if doesn't exist" do
      expect {
        remove_index :users, :login
      }.to raise_error
    end

    it "doesn't raise exception with :if_exists" do
      expect {
        remove_index :users, :login, :if_exists => true
      }.to_not raise_error
    end
  end

  protected
  def add_index(*args)
    migration.suppress_messages do
      migration.add_index(*args)
    end
    User.reset_column_information
  end

  def remove_index(*args)
    migration.suppress_messages do
      migration.remove_index(*args)
    end
    User.reset_column_information
  end

end
