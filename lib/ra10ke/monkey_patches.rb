# frozen_string_literal: true

class String
  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  # removes specified markes from string.
  # @return [String] - the string with markers removed
  def strip_comment(markers = ['#', "\n"])
    re = Regexp.union(markers)
    index = (self =~ re)
    index.nil? ? rstrip : self[0, index].rstrip
  end
end
