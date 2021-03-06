require 'opscode/expander/configuration'

module Opscode
  module Expander
    # Flattens and expands nested Hashes representing Chef objects
    # (e.g, Nodes, Roles, DataBagItems, etc.) into flat Hashes so the
    # objects are suitable to be saved into Solr. This code is more or
    # less copy-pasted from chef/solr/index which may or may not be a
    # great idea, though that does minimize the dependencies and
    # hopefully minimize the memory use of opscode-expander.
    class Flattener
      UNDERSCORE              = '_'
      X                       = 'X'

      X_CHEF_id_CHEF_X        = 'X_CHEF_id_CHEF_X'
      X_CHEF_database_CHEF_X  = 'X_CHEF_database_CHEF_X'
      X_CHEF_type_CHEF_X      = 'X_CHEF_type_CHEF_X'

      def initialize(item)
        @item = item
      end

      def flattened_item
        @flattened_item || flatten_and_expand
      end

      def flatten_and_expand
        @flattened_item = Hash.new {|hash, key| hash[key] = []}

        @item.each do |key, value|
          flatten_each([key.to_s], value)
        end

        @flattened_item.each_value { |values| values.uniq! }
        @flattened_item
      end

      def flatten_each(keys, values)
        case values
        when Hash
          values.each do |child_key, child_value|
            add_field_value(keys, child_key)
            flatten_each(keys + [child_key.to_s], child_value)
          end
        when Array
          values.each { |child_value| flatten_each(keys, child_value) }
        else
          add_field_value(keys, values)
        end
      end

      def add_field_value(keys, value)
        value = value.to_s
        @flattened_item[keys.join(UNDERSCORE)] << value
        @flattened_item[keys.last] << value
      end
    end
  end
end
