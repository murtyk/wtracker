# frozen_string_literal: true

module ModelHelpers
    COLOR_TURNOFF = 0
    COLOR_BLACK   = 30
    COLOR_RED     = 31
    COLOR_GREEN   = 32
    COLOR_YELLOW  = 33
    COLOR_BLUE    = 34
    COLOR_MAGENTA = 35
    COLOR_CYAN    = 36
    COLOR_WHITE   = 37
    COLOR_DEFAULT = 39

    BG_BLACK      = 40
    BG_RED        = 41
    BG_GREEN      = 42
    BG_YELLOW     = 43
    BG_BLUE       = 44
    BG_MAGENTA    = 45
    BG_CYAN       = 46
    BG_WHITE      = 47
    BG_DEFAULT    = 49

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def [](key)
        find(key)
      end

      def sample
        find(ids.sample)
      end

      def pample
        s = sample
        s.pretty
        s
      end
    end

    def pretty
      change_to_yellow
      pp attributes.sort.to_h
      turn_off_colors
      id
    end

    def change_to_yellow
      puts "\e[#{COLOR_YELLOW}m"
    end

    def turn_off_colors
      puts "\e[#{COLOR_TURNOFF}m"
    end
  end
