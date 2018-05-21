require 'sinatra'
require 'selenium-webdriver'
require 'phantomjs'

# require 'sinatra/reloader' if development?
# require 'byebug'

post '/' do
  begin
    echosign_url = params[:echosign_url]
    document_guid = params[:document_guid]

    if params[:echosign_url] && params[:document_guid]
      driver = Selenium::WebDriver.for :phantomjs
      wait = Selenium::WebDriver::Wait.new(timeout: 10) # define timeout
      driver.manage.window.maximize # biggest window size
      driver.navigate.to params[:echosign_url] # navigate to url specified in argument
      wait.until { driver.find_element(id: "document") } # wait until main page has been loaded
      driver.save_screenshot("tmp/#{document_guid}_01_visit_page.png")
      faux_field = driver.find_element(class: 'faux_field')
      faux_field.location_once_scrolled_into_view # scroll into view
      faux_field.click # click faux_field

      wait.until { driver.find_element(class: 'signing-control') } # wait until signing modal is visible

      sign_box = driver.find_element(class: 'signature-type-name')
      sign_box.click
      sign_box.send_keys "Prodigy Finance"

      sleep 2
      driver.save_screenshot("tmp/#{document_guid}_02_apply_signature.png")

      apply_btn = driver.find_element(class: 'apply')
      apply_btn.click

      wait.until { driver.find_element(class: 'click-to-esign').displayed? } # wait until click to esign button is visible
      driver.save_screenshot("tmp/#{document_guid}_03_completed_signature.png")
      

      esign_btn = driver.find_element(class: 'click-to-esign') # Click to Approve
      esign_btn.location_once_scrolled_into_view # scroll into view
      esign_btn.click  # click esign_btn

      wait.until { driver.find_element(id: 'download-signed-pdf') } # wait until download signed pdf button is visible
      sleep 2
      driver.save_screenshot("tmp/#{document_guid}_04_confirm_signature.png")
      driver.quit

      # here would be a good place to: 
      # - hit some sort of API endpoint back on platform to progress the signature process
      # - extract signatures to S3 bucket, and send it to platform
      # - send some sort of signature decision to platform
      "Countersigned."
    end

  rescue Selenium::WebDriver::Error::TimeOutError
    # Honeybadger etc
    # Notify Platform that somethnig went wrong
    exit(1)
  end

end