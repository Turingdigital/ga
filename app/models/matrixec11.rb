class Matrixec11 < ActiveRecord::Base

  def self.dates profileid
    where(profileid: profileid).select(:date).distinct.order(:date).map(&:date)
  end
  def self.ages profileid
    where(profileid: profileid).select(:age).distinct.order(:age).map(&:age)
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

  def self.date_to_transactions_hash profileid, hour, age=nil
    if age.nil?
      where(profileid: profileid, hour: hour).inject({}) {|h, row| h[row.date]=row.transactions;h}
    else
      where(profileid: profileid,  age: age, hour: hour).inject({}) {|h, row| h[row.date]=row.transactions;h}
    end
  end

  def self.transactions_array profileid, hour, age=nil
    datesAry = dates(profileid)
    transactions_hash = date_to_transactions_hash profileid, hour, age
    result = []
    datesAry.each {|d|
      result << (transactions_hash[d].nil? ? 0 : transactions_hash[d])
    }
    return result
  end
end
