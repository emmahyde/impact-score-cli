# frozen_string_literal: true

require "optparse"
require "impact_score"

module ImpactScore
  class CLI
    def self.start
      new.start
    end

    def start
      if ARGV.empty? || %w[-h --help help].include?(ARGV[0])
        return puts(help_text)
      end

      cmd = ARGV.shift
      case cmd
      when "compare"
        csv, user1, user2, opts = parse_args(3)
        calc = ImpactScore::Calculator.new(csv, weights: opts[:weights])
        c1, c2 = calc.compare(user1, user2)
        print_compare(user1, user2, c1, c2, opts[:weights])
      when "calc"
        csv, user, opts = parse_args(2)
        calc = ImpactScore::Calculator.new(csv, weights: opts[:weights])
        res = calc.calc(user)
        print_single(user, res, opts[:weights])
      else
        abort "Unknown command: #{cmd}\n\n#{help_text}"
      end
    end

    private

    def parse_args(min)
      opts = { weights: ImpactScore::Calculator::DEFAULT_WEIGHTS }
      parser = OptionParser.new do |o|
        o.on("--weights A,B,C,D", Array, "Weights as percentages (prs,quality,cycle,reviews)") do |arr|
          raise "Need 4 weights" unless arr.size == 4
          vals = arr.map { |x| x.to_f / 100.0 }
          opts[:weights] = ImpactScore::Weights.new(*vals)
        end
      end

      args = []
      while args.size < min && ARGV.any?
        args << ARGV.shift
      end
      parser.parse!(ARGV)
      [*args, opts]
    end

    def print_compare(u1, u2, c1, c2, w)
      puts "Weights: PRs #{(w.prs*100).to_i}%, Quality #{(w.quality*100).to_i}%, Cycle #{(w.cycle*100).to_i}%, Reviews #{(w.reviews*100).to_i}%"
      puts "%-25s %15s %15s %12s" % ["Component", u1, u2, "Δ"]
      puts "-" * 70
      %i[prs quality cycle reviews total].each do |k|
        v1 = c1[k]
        v2 = c2[k]
        puts "%-25s %15.2f %15.2f %12.2f" % [k.to_s.capitalize, v1, v2, v1 - v2]
      end
    end

    def print_single(u, c, w)
      puts "Weights: PRs #{(w.prs*100).to_i}%, Quality #{(w.quality*100).to_i}%, Cycle #{(w.cycle*100).to_i}%, Reviews #{(w.reviews*100).to_i}%"
      puts "%-25s %15s" % ["Component", u]
      puts "-" * 45
      %i[prs quality cycle reviews total].each do |k|
        v = c[k]
        puts "%-25s %15.2f" % [k.to_s.capitalize, v]
      end
    end

    def help_text
      <<~TXT
      impact-score – compute and compare impact scores from CSV

      Commands:
        impact-score compare CSV USER1 USER2 [--weights 75,5,15,5]
        impact-score calc CSV USER [--weights 75,5,15,5]

      CSV must contain columns: github_username, prs_per_week, avg_cycle_time_days, quality_reviews_per_week, reviews_per_week.
      TXT
    end
  end
end
