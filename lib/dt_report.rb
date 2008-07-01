## kinda too bad that reports are hard to generate with ActiveRecord

module DtReport
  class << self
    def time_from(col,range=6.month.ago)
      conds = []
      case range
      when Array
        from, to = range
      when Time
        from = range
        to = nil
      else
        from = nil
        to = nil
      end
      from = Time.parse from if from && !from.is_a?(Time)
      to = Time.parse to if to && !to.is_a?(Time)
      
      conds << "#{col} > #{connection.quote(from)}" if from
      conds << "#{col} < #{connection.quote(to)}" if to
      if !conds.empty?
        conds = conds.join " AND "
        "(#{conds})"
      else
        "true"
      end
    end

    def select_all(sql)
      acc = []
      connection.execute(sql).each_hash { |h| acc << h}
      acc
    end

    def connection
      @connection ||= ActiveRecord::Base.connection()
    end

    def by_countries(opts={})
      #opts.reverse_merge!()
      sql = <<-HERE
SELECT
PL2.name AS province,
Country.name AS country,
sum(I.amount) AS amount
FROM
projects AS P INNER JOIN
investments AS I INNER JOIN
places AS PL INNER JOIN
places AS PL2 INNER JOIN
places AS Country
ON P.id = I.project_id
AND PL.id = P.place_id
AND PL2.id = PL.parent_id
AND Country.id = PL2.parent_id

WHERE
#{time_from "I.created_at", opts[:time_from]} AND
P.partner_id != 4 AND
I.user_id != 218

GROUP BY Country.name
ORDER BY Country.name ASC;
HERE
      select_all(sql)
    end

    def by_partners(opts={})
      #opts.reverse_merge!({ :time_from => 6.month.ago})
      sql = <<-HERE
SELECT
PA.name AS name,
sum(I.amount) AS amount

FROM
projects AS P INNER JOIN
investments AS I INNER JOIN
partners AS PA
ON P.id = I.project_id
AND PA.id = P.partner_id

WHERE
#{time_from "I.created_at", opts[:time_from]} AND
P.partner_id !=4 AND
I.user_id != 218

GROUP BY P.partner_id;
HERE
      select_all(sql)
    end

    def by_projects(opts={})
      #opts.reverse_merge!({ :time_from => 6.month.ago})
      sql=<<-HERE
SELECT
PA.name AS partner_name,
P.id AS project_id,
P.name AS project_name,
sum(I.amount) AS amount,
P.total_cost

FROM
projects AS P INNER JOIN
investments AS I INNER JOIN
partners as PA
ON I.project_id = P.id
AND P.partner_id = PA.id

WHERE
#{time_from "I.created_at", opts[:time_from]} AND
P.partner_id != 4 AND
I.user_id != 218

GROUP BY P.id
ORDER BY PA.name ASC;
HERE
      select_all(sql)
    end

    def by_causes(opts={})
      sql = <<-HERE
SELECT
C.name AS cause,
sum(I.amount) AS amount
FROM

projects AS P INNER JOIN
causes AS C INNER JOIN
(SELECT * from causes_projects GROUP BY project_id) AS CP INNER JOIN
investments AS I

ON C.id = CP.cause_id
AND CP.project_id = P.id
AND I.project_id = P.id

WHERE
#{time_from "I.created_at", opts[:time_from]} AND
P.partner_id != 4

GROUP BY C.id;
HERE
      select_all(sql)
    end

  end

end
