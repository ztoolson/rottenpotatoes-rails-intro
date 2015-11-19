class Movie < ActiveRecord::Base
  def self.ratings
    %w(G PG PG-13 R).freeze
  end
end
