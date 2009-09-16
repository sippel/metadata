module PeopleHelper
  
  def contact_link(email)
    "<span id='email'>#{email.gsub(/@/,' at ')}</span>"
  end
    
  def parenthize(string)
    return string if string.nil?
    return string if string.strip == ""
    return "("+string+")"
  end
  
  
end
