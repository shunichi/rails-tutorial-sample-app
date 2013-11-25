require 'spec_helper'

describe "MicropostPages" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micro post creation" do
    before { visit root_path }

    describe "with invalid information" do
      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error message" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end

    describe "with valid information" do
      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect{ click_button 'Post' }.to change(Micropost, :count).by(1)
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end

    describe "as wrong user" do 
      let(:another_user) { FactoryGirl.create(:user) }
      before { 
        sign_in another_user 
        visit user_path(user)
      }

      it { should_not have_link('delete') }
    end
  end

  describe "micropost count" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "with single micropost" do
      before { visit root_path }

      it { should have_content('1 micropost') }
    end

    describe "with multiple microposts" do
      before do
        FactoryGirl.create(:micropost, user: user)
        visit root_path
      end

      it { should have_content('2 microposts') }
    end
  end

  describe "micrpost pagination" do
    before { 40.times { FactoryGirl.create(:micropost, user: user)}}
    before { visit root_path }

    it { should have_selector('div.pagination') }

    it "should list each micropost" do
      user.feed.paginate(page: 1).each do |mp|
        expect(page).to have_selector("li##{mp.id}", text: mp.content )
      end
    end

    it "should not list 2nd page's microposts" do
      user.feed.paginate(page: 2).each do |mp|
        expect(page).not_to have_selector("li##{mp.id}")
      end
    end
  end
end
