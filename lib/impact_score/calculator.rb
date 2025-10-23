# frozen_string_literal: true

require "csv"

module ImpactScore
  Weights = Struct.new(:prs, :quality, :cycle, :reviews)

  class Calculator
    DEFAULT_WEIGHTS = Weights.new(0.75, 0.05, 0.15, 0.05)

    def initialize(csv_path, weights: DEFAULT_WEIGHTS)
      @data = CSV.read(csv_path, headers: true)
      @weights = weights
      compute_medians!
    end

    def compare(user1, user2)
      u1 = find_user(user1)
      u2 = find_user(user2)
      raise "User not found: #{user1}" unless u1
      raise "User not found: #{user2}" unless u2

      c1 = contributions(u1)
      c2 = contributions(u2)
      [c1.merge(total: sum(c1)), c2.merge(total: sum(c2))]
    end

    def calc(user)
      u = find_user(user)
      raise "User not found: #{user}" unless u
      c = contributions(u)
      c.merge(total: sum(c))
    end

    private

    def find_user(username)
      @data.find { |r| r["github_username"] == username }
    end

    def compute_medians!
      active = @data.select { |r| r["prs_per_week"].to_f > 0 }
      prs_values = active.map { |r| r["prs_per_week"].to_f }.sort
      cycle_values = active.map { |r| r["avg_cycle_time_days"].to_f }.sort
      @median_prs = median(prs_values)
      @median_cycle = median(cycle_values)
    end

    def median(values)
      return 0.0 if values.empty?
      mid = values.length / 2
      values.length.odd? ? values[mid].to_f : (values[mid - 1].to_f + values[mid].to_f) / 2.0
    end

    def contributions(row)
      prs = row["prs_per_week"].to_f
      qrv = row["quality_reviews_per_week"].to_f
      cyc = row["avg_cycle_time_days"].to_f
      rvw = row["reviews_per_week"].to_f

      prs_pts = (prs - @median_prs) * @weights.prs
      qual_pts = qrv * @weights.quality
      cycle_pts = (@median_cycle - cyc) * @weights.cycle
      reviews_pts = rvw * @weights.reviews

      {
        prs: round2(prs_pts),
        quality: round2(qual_pts),
        cycle: round2(cycle_pts),
        reviews: round2(reviews_pts)
      }
    end

    def sum(h)
      round2(h[:prs] + h[:quality] + h[:cycle] + h[:reviews])
    end

    def round2(x) = (x.to_f * 100).round / 100.0
  end
end
