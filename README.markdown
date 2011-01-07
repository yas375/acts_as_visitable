# ActsAsVisitable

With this plugin you can simply implement counter of page views.

## Setup

Install plugin:

    ./script/plugin install git://github.com/yas375/acts_as_visitable.git

or you can add this plugin as submodule:

    git submodule add git://github.com/yas375/acts_as_visitable.git vendor/plugins/acts_as_visitable


Create new migration file and insert to it:

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

Run migration and after that insert belongs_to to new model VisitsCounter in your app/models:

    class VisitsCounter < ActiveRecord::Base
      belongs_to :visitable, :polymorphic => true
    end

## Usage

Once you have installed the plugin you can start using it in your ActiveRecord models simply by calling the acts_as_visitable method.

    class Post < ActiveRecord::Base
      acts_as_visitable
    end

To get visits counter fo post simply call _visits_ method:

    Post.first.visits

To increment visits counter use _increment_visits_

    Post.first.increment_visits

for example you can insert it to _show_ method in your controller:

    class PostController < ApplicationController
      def show
        @post = Post.find(params[:id])
        @post.increment_visits
      end
    end

Or you can use increment exactly in view:

    = "Pageviews: #{@post.incremen_visits}"

I use here _increment_visits_ instead of _visits_ because increment_visits firstly incryment visits count and return new value for you.

## How it works

When you call Post.first.visits it's try to find visits_counter for this model and if it's not found, than create it and return 0 as visits count.
And if visits_counter already exists than method visits will simply return count of visits from there.

The same situation with increment_visits. If visits_counter not exists than it will be created.

Also plugin includes after_create callback for creating visits_counter association with creating of your object.

It means that you shouldn't worry about creating visits_counters for new and old objects. Just use it!

Copyright (c) 2010 Ilyukevich Victor, released under the MIT license
