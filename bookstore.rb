require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'debugger'

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
      select_state()
      select_institution()
      visit_textbooks_page()

      select_program
      select_term
      select_department
      select_course
      select_section
      submit_textbooks

      parse_course_materials
    end

    def visit_front_page
      puts "Visiting front page"
      visit("/")
    end

    def select_state
      puts "Selecting state"
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

      wait_until { current_path.start_with? "/CategoryDisplay" }
    end

    def select_program
      select "All", :from => "programId"
    end

    def select_term
      select "Fall 2012", :from => "termId"
    end

    def select_department
      wait_until { find(:xpath, "//*[@id='departmentIdSelect']").all("option").count > 1 }

      departments = find(:xpath, "//*[@id='departmentIdSelect']").all("option")
      departments.shift

      select departments.first.text, :from => "departmentIdSelect"
    end

    def select_course
      wait_until { find(:xpath, "//*[@id='courseIdSelect']").all("option").count > 1 }

      courses = find(:xpath, "//*[@id='courseIdSelect']").all("option")
      courses.shift

      select courses.first.text, :from => "courseIdSelect"
    end

    def select_section
      wait_until { find(:xpath, "//*[@id='sectionIdSelect']").all("option").count > 1 }

      sections = find(:xpath, "//*[@id='sectionIdSelect']").all("option")
      sections.shift

      select sections.first.text, :from => "sectionIdSelect"
    end

    def submit_textbooks
      wait_until { find_button "Submit" }

      click_button "Submit"
    end

    def parse_course_materials
      wait_until { current_path.start_with? "/webapp/wcs/stores/servlet/CourseMaterialsResultsView" }

      puts "Wohoo"
    end
  end
end

Bookstore.scrape_all()
