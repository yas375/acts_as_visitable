module ActiveRecord
  module Acts
    module Visitable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_visitable
          has_one :visits_counter, :as => :visitable, :dependent => :destroy
          after_create :new_visits_counter

          class_eval <<-EOV
            def visits
              counter = new_visits_counter || visits_counter
              counter.count
            end

            def increment_visits
              counter = visits_counter || new_visits_counter
              counter.increment(:count).save
              counter.count
            end

            private
            def new_visits_counter
              VisitsCounter.create(:visitable => self) if visits_counter.nil?
            end
          EOV
        end
      end
    end
  end
end
