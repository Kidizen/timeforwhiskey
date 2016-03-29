require "time"

class SalesController < ApplicationController
  http_basic_authenticate_with name: "kidizen", password: "itzn1212"
  respond_to :json

  @@sales = {}
  @@last_seen = Time.now

  def index
    @sales = SalesController.get_sales
  end

  def self.get_sales

    if @@sales.empty? or @@last_seen < 10.seconds.ago

      @@last_seen = Time.now

      connection = ActiveRecord::Base.connection
      res = connection.execute("select tmp.date as date, sum(tmp.amount) as total, sum(case when tmp.created_through = 'ios' then tmp.amount else null end) as ios, sum(case when tmp.created_through = 'android' then tmp.amount else null end) as android, sum(case when tmp.seller_fee_strategy = 'Percentage' then tmp.amount else null end) as kidbucks, round(sum(case when tmp.seller_fee_strategy = 'Percentage' then tmp.amount else null end)/sum(tmp.amount),4) as kidbucks_percent from(select date_trunc('day',(o.purchase_date::TIMESTAMP WITH TIME ZONE) AT TIME ZONE 'CDT') as date, o.id as order_id, case when o.created_through is null then case when u.created_through = 'android' then u.created_through else 'ios' end else o.created_through end as created_through, o.fee_strategy_info->>'strategy_name' as seller_fee_strategy, round(sum(p.amount_cents)/100.0,2) as amount from orders o left join payments p on p.order_id = o.id left join users u on o.user_id = u.id where o.aasm_state = 'completed' and p.aasm_state = 'successful' and date_trunc('day',(o.purchase_date::TIMESTAMP WITH TIME ZONE) AT TIME ZONE 'CDT') = CURRENT_DATE group by date_trunc('day',(o.purchase_date::TIMESTAMP WITH TIME ZONE) AT TIME ZONE 'CDT'), o.id, case when o.created_through is null then case when u.created_through = 'android' then u.created_through else 'ios' end else o.created_through end, o.fee_strategy_info->>'strategy_name' order by 1 desc) tmp group by tmp.date order by tmp.date desc")
      total = res[0]['total']
      @@sales = {
          "total" => total,
          "ios" => res[0]['ios'],
          "android" => res[0]['android'],
          "kidbucks" => res[0]['kidbucks'],
          "kb_percent" => res[0]['kidbucks_percent'].to_s,
          "success" => (total.to_f >= 8000)
      }
      Rails.logger.error("res[0]['kidbucks_percent']: " + res[0]['kidbucks_percent'])
      Rails.logger.error("res[0]['kidbucks_percent'].to_f: " + res[0]['kidbucks_percent'].to_f)
      Rails.logger.error("res[0]['kidbucks_percent'].to_s: " + res[0]['kidbucks_percent'].to_s)
      Rails.logger.error("response: " + res)
    end

    @@sales
  end
end
