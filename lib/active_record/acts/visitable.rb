module ActiveRecord
  module Acts
    module Visitable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_visitable(options = {})
          configuration = { :full_log => false }
          configuration.update(options) if options.is_a?(Hash)

          has_one :visits_counter, :as => :visitable, :dependent => :destroy
          after_create :new_visits_counter

          if configuration[:full_log]
            has_many :visits_logs, :as => :loggable, :dependent => :destroy
          end

          class_eval do
            def visits
              counter = new_visits_counter || visits_counter
              counter.count
            end

            def increment_visits
              counter = visits_counter || new_visits_counter
              counter.increment(:count).save
              counter.count
            end

            if configuration[:full_log]
              def add_log(user, ip)
                increment_visits
                VisitsLog.create(:loggable => self, :user => user, :ip => ip)
              end
            end

            private
            def new_visits_counter
              VisitsCounter.create(:visitable => self) if visits_counter.nil?
            end
          end
        end
      end
    end
  end
end
