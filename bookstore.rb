require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'

Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.default_wait_time = 4

module Bookstore 
  def self.scrape_all
    Follett.new
  end

  class Follett
    include Capybara::DSL

    Capybara.app_host = "http://www.bkstr.com"

    def initialize
      visit_front_page()
      get_states()
      select_institution()
      visit_textbooks_page()
    end

    def visit_front_page
      puts "Visiting front page"
      visit("/")
    end

    def get_states
      puts "Getting states"
      states = find(:xpath, "//*[@id='stateUSAIdSelect']").all("option")
      states.shift # Push off the first element with text 'Select your State'

      select states[0].text, :from => 'Select Your State'

    end

    def select_institution
      puts "Selecting institution"

      wait_until { all(:xpath, "//select[@id='institutionUSAIdSelect']/option").count > 1 } # Find and wait for options to appear

      institutions = find(:xpath, "//*[@id='institutionUSAIdSelect']").all("option")
      institutions.shift # Remove 'Select Your Institution' element
       
      select institutions[0].text, :from => "Select Your Institution"
      
      wait_until { find_button "Submit" }

      click_button "Submit"

      wait_until { current_path == "/webapp/wcs/stores/servlet/StoreCatalogDisplay" }
    end

    def visit_textbooks_page
      puts "Visiting textbooks_page"

      find(:xpath, "//*[@id='efContentHome']/div[2]/a").click

      wait_until { current_path.starts_with "/CategoryDisplay" }

      puts page.html
    end
  end
end

Bookstore.scrape_all()
