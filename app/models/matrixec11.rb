class Matrixec11 < ActiveRecord::Base
  validates :hour, uniqueness: { scope: [:date, :age] }

  def self.dates profileid, _start, _end
    where(profileid: profileid).where("date >= ? and date <=?", _start, _end).select(:date).distinct.order(:date).map(&:date)
  end
  def self.ages profileid, _start, _end
    where(profileid: profileid).where("date >= ? and date <=?", _start, _end).select(:age).distinct.order(:age).map(&:age)
  end

  # def self.sum_hour_transactions hour, age=nil
  #   if age.nil?
  #     where(hour: hour).inject(0) {|sum, row| sum+row.transactions}
  #   else
  #     where(age: age, hour: hour).inject(0) {|sum, row| sum+row.transactions}
  #   end
  # end

  def self.sum_date_transactions profileid, date, age=nil
    if age.nil?
      where(profileid: profileid, date: date).inject(0) {|sum, row| sum+row.transactions}
    else
      where(profileid: profileid, age: age, date: date).inject(0) {|sum, row| sum+row.transactions}
    end
  end

  def self.date_to_transactions_hash profileid, _start, _end, hour, age=nil
    if age.nil?
      where(profileid: profileid, hour: hour).where("date >= ? and date <=?", _start, _end).inject({}) {|h, row|
        h[row.date]=0 if h[row.date].nil?
        h[row.date]+=row.transactions
        h
      }
    else
      where(profileid: profileid,  age: age, hour: hour).where("date >= ? and date <=?", _start, _end).inject({}) {|h, row| h[row.date]=row.transactions;h}
    end
  end

  def self.transactions_array profileid, _start, _end, hour, age=nil
    datesAry = dates(profileid, _start, _end)
    transactions_hash = date_to_transactions_hash profileid, _start, _end, hour, age
    result = []
    datesAry.each {|d|
      result << (transactions_hash[d].nil? ? 0 : transactions_hash[d])
    }
    return result
  end

  def self.sum_date_revenue profileid, date, age=nil
    if age.nil?
      where(profileid: profileid, date: date).inject(0) {|sum, row| sum+row.revenue}
    else
      where(profileid: profileid, age: age, date: date).inject(0) {|sum, row| sum+row.revenue}
    end
  end

  def self.date_to_revenue_hash profileid, _start, _end, hour, age=nil
    if age.nil?
      where(profileid: profileid, hour: hour).where("date >= ? and date <=?", _start, _end).inject({}) {|h, row|
        h[row.date]=0 if h[row.date].nil?
        h[row.date]+=row.revenue
        h
      }
    else
      where(profileid: profileid,  age: age, hour: hour).where("date >= ? and date <=?", _start, _end).inject({}) {|h, row| h[row.date]=row.revenue;h}
    end
  end

  def self.revenue_array profileid, _start, _end, hour, age=nil
    datesAry = dates(profileid, _start, _end)
    revenue_hash = date_to_revenue_hash profileid, _start, _end, hour, age
    result = []
    datesAry.each {|d|
      result << (revenue_hash[d].nil? ? 0 : revenue_hash[d])
    }
    # byebug
    return result
  end
end
