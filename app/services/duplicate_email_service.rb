class DuplicateEmailService
  def self.call
    Client.group(:email).having('count(*) > 1').pluck(:email)
  end
end