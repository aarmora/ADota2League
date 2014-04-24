module Shadchan
=begin rdoc
Solves Stable Roommates problem. From n 'roommates', who all have a preference about each other,
it creates such pairing that no roommate would be happier with other AND the other would be
happier with the roommate.

http://en.wikipedia.org/wiki/Stable_roommates_problem

Problem is not always solvable. In that case it raises Shadchan::NotSolvable exception.
=end
  class Roomie
=begin rdoc
Initialize problem. Takes preference lists in form [most_prefered_index, second_most_prefered_index, ...].
Example:
  Shachdan::Roomie.new [2,3,1,5,4],[5,4,3,0,2],[1,3,4,0,5],[4,1,2,5,0],[2,0,1,3,5],[4,0,2,3,1]
or
  a = [[2,3,1,5,4],[5,4,3,0,2],[1,3,4,0,5],[4,1,2,5,0],[2,0,1,3,5],[4,0,2,3,1]]
  Shachdan::Roomie.new *a

Will raise Shachdan::NotSolvable if solution cannot be found.
=end
    def initialize *args
      check_input args
      @preferences = args.map(&:dup)
      @size = @preferences.size
      @match = []
      stable_matching
    end
=begin rdoc
Returns array of matches. Numbering corresponds to that used to initialize this instance.
  shachdan = Shachdan::Roomie.new *a
  shachdan.match #=> [5,4,3,1,2,0]

In this example, roommate 0 was matched with roommate 5, roommate 1 with roommate 4 etc.
=end
    def match
      @reversed_matches
    end

    private
    def stable_matching
      propose
      if is_matching?
        @reversed_matches = @matches
        return true
      end
      reverse_matches
#      puts @matches.inspect
#      puts @reversed_matches.inspect
#      puts @modified_preferences.inspect
      rotate_solutions
    end

    def reverse_matches
      @reversed_matches = Array.new(@size)
      @matches.each_with_index do |e, i|
        @reversed_matches[e] = i
      end
    end


    def rotate_solutions
      until is_matching?
        rot = generate_rotation
#puts rot.inspect
        apply_rotation(rot)
#        puts @reversed_matches.inspect
      end
    end

    def apply_rotation(rot)
      rot.each do |r|
        @reversed_matches[r.first] = r.last
        @matches[r.last] = r.first
      end
    end

    def generate_rotation
      rotation = []
      @reversed_matches.each_with_index do |e, i|
        unless @reversed_matches[e] == i then
          current = i
          begin
          # get second favorite
            second_favorite = @modified_preferences[current].shift
            rotation << [current, second_favorite]
            current = @reversed_matches.find_index(second_favorite)
#puts rotation.inspect
#           puts @modified_preferences.inspect
#           puts "sf = #{second_favorite}"
#           puts "e = #{e}"
#           puts "i = #{i}"
#           puts "current = #{current}"
          end while second_favorite != e
          return rotation
        end
      end
      rotation
    end

    def propose
      @matches = Array.new(@size)
      @modified_preferences = @preferences.map(&:dup)

      while r = free_roommate
        desired = @modified_preferences[r].shift
        raise NotSolvable, 'Problem has no solution' if desired.nil?
        if @matches[desired] then
          if @preferences[desired].find_index(r) < @preferences[desired].find_index(@matches[desired]) then
            @matches[desired] = r
          end
        else
          @matches[desired] = r
          next
        end
      end
    end

    def is_matching?
      @matches.each_with_index do |e, i|
        return false unless @matches[e] == i
      end
      true
    end

    def free_roommate
      @size.times do |i|
        not_proposed = !@matches.include?(i)
        if not_proposed then
          return i
        end
      end
      return nil
    end

    def check_input args
      raise ArgumentError, 'No arguments given' if args.empty?
      size = args.first.size

      unless args.all?{|w| w.size == size} then
        raise ArgumentError, 'Incorrectly specified input - inconsistent preference list size. Check your input.'
      end

      unless args.size == size+1 then
        raise ArgumentError, 'Incorrectly specified input - preference lists too small or big. Check your input.'
      end

      unless args.size.even?
        raise ArgumentError, 'Not valid problem - number of roommates must be even.'
      end

      args.each_with_index do |e, i|
        size.times do |j|
          unless i==j then
            raise ArgumentError, 'Error in input - each roommate must state preference for all other except himself' unless e.include? j
          end
        end
      end
    end
  end
end