=begin
The MIT License

Copyright (c) 2010 Adam Kapelner and Dana Chandler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

module BmomMTurk
  include RTurkWrapper

  WordTurkMTurkVersion = "0.2b"
  ExperimentalController = 'training'
  #hit defaults
  DEFAULT_HIT_TITLE = "#{Rails.env.development? ? "SANDBOX " : ""}#{Rails.env.development? ? "LAPTOP " : ""}Find Objects of Interest in Images (new!) --- $#{MHit::WAGES.first} + unlimited bonus!!"
  DEFAULT_HIT_DESCRIPTION = %Q|You will be given an image and "objects of interest" to find. Your task is to click on the "objects of interest".  Before beginning, there will be a brief tutorial. After completing the first image, there will be a potential opportunity to complete ***unlimited*** similar HITs.|
  DEFAULT_HIT_KEYWORDS = "find objects, images, click on areas of interest, object labeling, computer vision"
  DEFAULT_ASSIGNMENT_DURATION = 60 * 60 * 3 # 3hr marathon baby!
  DEFAULT_HIT_LIFETIME = 60 * 57 # 57min in order so that there won't be overlap among the batches
  DEFAULT_ASSIGNMENT_AUTO_APPROVAL = 60 * 60 * 2 * 24 # 48hrs in case cron jobs fail
  DEFAULT_FRAME_HEIGHT = 800

  def create_bmom_hit_on_mturk(hit, options = {})
    options[:title] ||= DEFAULT_HIT_TITLE
    options[:description] ||= DEFAULT_HIT_DESCRIPTION
    options[:keywords] ||= DEFAULT_HIT_KEYWORDS
    options[:assignment_duration] ||= DEFAULT_ASSIGNMENT_DURATION
    options[:lifetime] ||= DEFAULT_HIT_LIFETIME
    options[:assignment_auto_approval] ||= DEFAULT_ASSIGNMENT_AUTO_APPROVAL
    options[:frame_height] ||= DEFAULT_FRAME_HEIGHT
    #stuff that's more likely to change
    options[:country] = hit.experimental_country_to_text
    options[:wage] = hit.initial_wage
    #for the actual url that hits our server (do not touch)
    options[:render_url] = "/#{ExperimentalController}?hit_id=#{hit.encrypted_id}"
    #create the hit and return its data
    mturk_create_hit(options)
  end
end