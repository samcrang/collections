require 'integration_test_helper'

class TravelAdviceTest < ActionDispatch::IntegrationTest
  def assert_has_component_title(title, context = nil)
    within shared_component_selector("title") do
      component_data = JSON.parse(page.text)
      assert_equal title, component_data.fetch("title")
      assert_equal context, component_data.fetch("context") if context
    end
  end

  GovukContentSchemaTestHelpers.configure do |config|
    config.schema_type = 'frontend'
    config.project_root = Rails.root
  end

  # Necessary because Capybara's has_content? method normalizes spaces in the document
  # However, it doesn't normalize spaces in the query string, so if you're looking for a string
  # with 2 spaces in it (e.g. when the date is a single digit with a space prefix), it will fail.
  def de_dup_spaces(string)
    string.gsub(/ +/, ' ')
  end

  context "index" do
    setup do
      stub_shared_component_locales

      json = GovukContentSchemaTestHelpers::Examples.new.get('travel_advice_index', 'index')
      content_item = JSON.parse(json)
      base_path = content_item.fetch("base_path")

      content_store_has_item(base_path, content_item)
    end

    should "display the list of countries" do
      visit '/foreign-travel-advice'

      assert_equal 200, page.status_code

      within 'head', visible: :all do
        assert page.has_selector?("title", text: "Foreign travel advice", visible: :all)
        assert page.has_selector?("link[rel=alternate][type='application/atom+xml'][href='/foreign-travel-advice.atom']", visible: :all)
        assert page.has_selector?("meta[name=description][content='Latest travel advice by country including safety and security, entry requirements, travel warnings and health']", visible: false)
      end

      assert page.has_selector?("#wrapper.travel-advice")

      within '#content' do
        within 'header' do
          assert page.has_content?("Foreign travel advice")
        end

        assert page.has_selector?("#country-filter")

        names = page.all("ul.countries li a").map(&:text)
        assert_equal %w(Afghanistan Austria Finland India Malaysia São\ Tomé\ and\ Principe Spain), names

        within ".list#A" do
          assert page.has_link?("Afghanistan", href: "/foreign-travel-advice/afghanistan")
        end

        within ".list#M" do
          assert page.has_link?("Malaysia", href: "/foreign-travel-advice/malaysia")
        end

        within ".list#S" do
          assert page.has_link?("Spain", href: "/foreign-travel-advice/spain")
        end
      end

      group_headers = page.all(".list h2").map(&:text)
      assert_equal group_headers.sort, group_headers
    end

    should "have the correct titles" do
      visit '/foreign-travel-advice'

      assert_has_component_title "Foreign travel advice"
      assert_equal "Foreign travel advice - GOV.UK", page.title
    end

    should "set the slimmer #wrapper classes" do
      visit '/foreign-travel-advice'
      assert_equal "travel-advice", page.find("#wrapper")["class"]
    end
  end

  context "index with the javascript driver" do
    setup do
      json = GovukContentSchemaTestHelpers::Examples.new.get('travel_advice_index', 'index')
      content_item = JSON.parse(json)
      base_path = content_item.fetch("base_path")
      content_store_has_item(base_path, content_item)

      Capybara.current_driver = Capybara.javascript_driver
    end

    should "load the page and perform filtering correctly" do
      visit "/foreign-travel-advice"
      assert_equal 200, page.status_code

      # For some reason PhantomJS isn't executing this script at the top of the <body> element,
      # so we have to repeat it here.
      page.execute_script "document.body.className = ((document.body.className) ? document.body.className + ' js-enabled' : 'js-enabled');"

      assert page.has_selector?("#country-filter")

      within "#country-filter" do
        fill_in "country", with: "In"
      end

      within ".countries-wrapper" do
        assert page.has_selector?("#I li") # _In_dia
        assert page.has_selector?("#F li") # F_in_land
        assert page.has_selector?("#S li") # Spa_in_
        assert page.has_no_selector?("#A li")
        assert page.has_no_selector?("#M li")
      end

      within ".country-count" do
        assert page.has_selector?(".js-filter-count", text: "4")
      end
    end
  end
end
