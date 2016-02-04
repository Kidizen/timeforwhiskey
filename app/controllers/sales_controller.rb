require "time"

class SalesController < ApplicationController
  http_basic_authenticate_with name: "kidizen", password: "itzn1212"
  respond_to :json

  def index
    connection = ActiveRecord::Base.connection
    res = connection.execute("select date_trunc('day',(o.purchase_date::TIMESTAMP WITH TIME ZONE) AT TIME ZONE 'CDT') as \"Date\", round(sum(p.amount_cents)/100.0,2) as \"total\", round(sum(case when o.created_through = 'ios' then p.amount_cents else null end)/100.0,2) as \"ios\", round(sum(case when o.created_through = 'android' then p.amount_cents else null end)/100.0,2) as \"android\" from orders o left join payments p on p.order_id = o.id where o.aasm_state = 'completed' and p.aasm_state = 'successful' and (o.purchase_date::TIMESTAMP WITH TIME ZONE) AT TIME ZONE 'CDT' >= '2013-12-01' group by date_trunc('day',(o.purchase_date::TIMESTAMP WITH TIME ZONE) AT TIME ZONE 'CDT') order by 1 desc limit 1")
    total = res[0]['total']
    @sales = {
        "total" => total,
        "ios" => res[0]['ios'],
        "android" => res[0]['android'],
        "success" => (total.to_f >= 8000)
    }
  end

  def before_5_pm(time)
    time.hour <= 17
  end
end
