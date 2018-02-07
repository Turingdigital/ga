class AccountSummary < ActiveRecord::Base
  belongs_to :user

  def hash
    return JSON.parse self.jsonString
  end

  def default_ga_setting_names
    h = {item: find_item}
    h[:web_property] = find_web_property_from_item h[:item]
    h[:profile] = find_profile_from_web_property h[:web_property]
    return {item: h[:item]["name"], web_property: h[:web_property]["name"], profile: h[:profile]["name"]}
  end

  class << self

    def find_com_name_by_profile profile_id, user=User.where(email: "analytics@turingdigital.com.tw").first
      result = nil
      # cnt = 0
      begin
        AccountSummary.where(user: user).each {|as|
          (JSON.parse as.jsonString)["items"].each {|it|
              it["web_properties"].each {|wp|
                next if wp["profiles"].nil?
                # byebug if cnt == 0
                # cnt += 1
                result = wp["profiles"].find {|o| profile_id == o["id"]}
                # byebug if Rails.env=="development" && wp["id"]=="UA-54830988-1"
                unless result.nil?
                  # byebug if Rails.env=="development"
                  return "#{it['id']}.#{it['name']}"
                end
                # wp["profiles"].each {|prof|  }
            } if it["web_properties"]
          } if (JSON.parse as.jsonString)["items"]
        }

        AccountSummary.where(user: user).not(user: user).each {|as|
          (JSON.parse as.jsonString)["items"].each {|it|
              it["web_properties"].each {|wp|
                result = wp["profiles"].find {|o| profile_id == o["id"]}
                unless result.nil?
                  # byebug if Rails.env=="development"
                  return "#{it['id']}.#{it['name']}"
                end
                # wp["profiles"].each {|prof|  }
            } if it["web_properties"]
          } if (JSON.parse as.jsonString)["items"]
        }
      rescue
        byebug if Rails.env=="development"
      end

      # AccountSummary.where.not(user: user).each {|as|
      #   result = (JSON.parse as.jsonString)["items"].find {|o| profile_id == o["id"]}
      # } if result.nil?
      # byebug if Rails.env=="development"
      # (result.nil? ? nil : result["name"])
      byebug if Rails.env=="development"
      false
    end

    def re_fetch user
      analytics = Analytics.new user
      result = analytics.accountSummaries
      if result
        ac = self.where(user: user)
        if ac.size > 0
          ac = ac.first
          ac.jsonString = result.to_json
          ac.save
        else
          self.create(user: user, jsonString: result.to_json)
        end
      end
    end

    def fetch user
      analytics = Analytics.new user
      result = analytics.accountSummaries
      self.create(user: user, jsonString: result.to_json) if result
    end
  end

  private
    def find_item
      result = JSON.parse(self.jsonString)['items'].index_by{|item| item["id"]==self.default_item}
      return result[true].nil? ? result[false] : result[true]
    end

    def find_web_property_from_item item
      result = item["web_properties"].index_by{|web_property| web_property["id"]==self.default_web_property}
      return result[true].nil? ? result[false] : result[true]
    end

    def find_profile_from_web_property web_property
      result = web_property["profiles"].index_by{|profile| profile["id"]==self.default_profile}
      return result[true].nil? ? result[false] : result[true]
    end
end
