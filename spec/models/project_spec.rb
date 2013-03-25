require File.dirname(__FILE__) + '/../spec_helper'

describe Project do

  describe "not_unique_worker_for_quality_control?" do

    WorkerIdToFind = 'correct_id'
    
    before(:each) do
      @project = Project.create(:user_id => 1, :name => 'test project')
    end

    it "should return false if worker id is nil" do
      @project.not_unique_worker_for_quality_control?(nil).should == false
    end

    it "should return false if not a quality control project" do
      i = Image.new
      i.project = @project
      i.filename = "fake"
      i.height = 100
      i.width = 100
      i.worker_id = WorkerIdToFind
      i.save!
      @project.not_unique_worker_for_quality_control?(WorkerIdToFind).should == false
    end

    it "should return false if the worker id is not found" do
      3.times do |n|
        p = Project.create(:user_id => 2, :name => "test project #{n}", :quality_control => true)
        3.times do |j|
          i = Image.new
          i.project = p
          i.filename = "fake#{n}_#{j}"
          i.height = 100
          i.width = 100
          i.worker_id = 'afrgefgdsdf'.split('').sort_by{rand}.join
          i.save!
        end
      end
      @project.not_unique_worker_for_quality_control?(WorkerIdToFind).should == false
    end

    it "should return false if the worker id is found but the project is not a quality control project" do
      3.times do |n|
        p = Project.create(:user_id => 2, :name => "test project #{n}", :quality_control => true)
        3.times do |j|
          i = Image.new
          i.project = p
          i.filename = "fake#{n}_#{j}"
          i.height = 100
          i.width = 100
          i.worker_id = 'afrgefgdsdf'.split('').sort_by{rand}.join
          i.save!
        end
      end
      p = Project.create(:user_id => 2, :name => "test project with_target")
      i = Image.new
      i.project = p
      i.filename = "fake test case"
      i.height = 100
      i.width = 100
      i.worker_id = WorkerIdToFind
      i.save!
      @project.not_unique_worker_for_quality_control?(WorkerIdToFind).should == false
    end

    it "should return true if both the worker id is found in another project and the project is qc project" do
      3.times do |n|
        p = Project.create(:user_id => 2, :name => "test project #{n}", :quality_control => true)
        3.times do |j|
          i = Image.new
          i.project = p
          i.filename = "fake#{n}_#{j}"
          i.height = 100
          i.width = 100
          i.worker_id = 'afrgefgdsdf'.split('').sort_by{rand}.join
          i.save!
        end
      end
      p = Project.create(:user_id => 2, :name => "test project with_target", :quality_control => true)
      i = Image.new
      i.project = p
      i.filename = "fake test case"
      i.height = 100
      i.width = 100
      i.worker_id = WorkerIdToFind
      i.save!
      @project.update_attributes(:quality_control => true)
      @project.not_unique_worker_for_quality_control?(WorkerIdToFind).should == true
    end
    
  end

end