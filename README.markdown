# ActsAsVisitable

This plugin can simply counts number of visits for any model (it uses polymorphic association) and (if needed) it can save info about every visit (also with polymorphic association).
For example in my project I save visits counter for newsitems and also I save info about users who downloaded files. And I know how many and which exactly files who downloaded.

This plugin uses two models: VisitsCounter and VisitsLog. Last is optional and needed only if you would like to save info about every visit.

## Setup

Install plugin:

    ./script/plugin install git://github.com/yas375/acts_as_visitable.git

or you can add this plugin as submodule:

    git submodule add git://github.com/yas375/acts_as_visitable.git vendor/plugins/acts_as_visitable

Create new migration with next content:

    class CreateVisitsCounters < ActiveRecord::Migration
      def self.up
        create_table :visits_counters do |t|
          t.integer :visitable_id
          t.string  :visitable_type
          t.integer :count, :default => 0

          t.timestamps
        end
      end

      def self.down
        drop_table :visits_counters
      end
    end

Create app/models/visits\_counter.rb with::

    class VisitsCounter < ActiveRecord::Base
      belongs_to :visitable, :polymorphic => true
    end

If you want also save logs about every visits than you will need also create migration:

    class CreateVisitsLogs < ActiveRecord::Migration
      def self.up
        create_table :visits_logs do |t|
          t.integer :loggable_id
          t.string :loggable_type
          t.string :ip
          t.references :user

          t.timestamps
        end
      end

      def self.down
        drop_table :visits_logs
      end
    end

And model in app/models/visits_log.rb:

    class VisitsLog < ActiveRecord::Base
      belongs_to :loggable, :polymorphic => true
      belongs_to :user
    end


## Usage

Once you have installed the plugin you can start using it in your ActiveRecord models simply by calling the acts\_as\_visitable method.

    class Post < ActiveRecord::Base
      acts_as_visitable
    end

To get visits counter fo post simply call _visits_ method:

    Post.first.visits

To increment visits counter use _increment\_visits_

    Post.first.increment_visits

for example you can insert it to _show_ method in your controller:

    class PostController < ApplicationController
      def show
        @post = Post.find(params[:id])
        @post.increment_visits
      end
    end

Or you can use increment exactly in view:

    = "Pageviews: #{@post.increment_visits}"

I use here _increment\_visits_ instead of _visits_ because increment_visits firstly increment visits count and return new value for you.

### With full log

If you need to save log about visits (not only counter) than pass option :full_log as true to acts\_as\_visitable:

    class Attach < ActiveRecord::Base
      acts_as_visitable :full_log => true
    end

And in controller where you want to add record to log call:

    @attach.add_log(current_user, request.remote_addr)

To get all logs for some object (i.e. my @attach) use:

    @attach.visits_logs

For getting visits by user add to you User model association *has_many :visits_logs*. For example like this:

    has_many :visits_logs, :dependent => :nullify

And than call:

    @user.visits_logs

## How it works

When you call Post.first.visits it's try to find visits_counter for this model and if it's not found, than create it and return 0 as visits count.
And if visits\_counter already exists than method visits will simply return count of visits from there.

The same situation with increment\_visits. If visits\_counter not exists than it will be created.

Also plugin includes after\_create callback for creating visits\_counter association with creating of your object.

It means that you shouldn't worry about creating visits\_counters for new and old objects. Just use it!

And when you use full\_log feature and call _add\_log(user)_ method than it will increment visits counter and create record in VisitsLog about user and material which he viewed.

Copyright (c) 2010 Ilyukevich Victor, released under the MIT license
