# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 54) do

  create_table "big_brother_params", :force => true do |t|
    t.string  "param"
    t.text    "value"
    t.integer "big_brother_track_id"
  end

  add_index "big_brother_params", ["big_brother_track_id"], :name => "index_big_brother_params_on_big_brother_track_id"

  create_table "big_brother_tracks", :force => true do |t|
    t.integer  "user_id"
    t.string   "user_login"
    t.string   "ip"
    t.string   "controller"
    t.string   "action"
    t.string   "method"
    t.boolean  "ajax"
    t.string   "entry"
    t.string   "language"
    t.datetime "created_at"
  end

  add_index "big_brother_tracks", ["ip"], :name => "index_big_brother_tracks_on_ip"

  create_table "color_blindness_tests", :force => true do |t|
    t.integer  "worker_id"
    t.integer  "number_in_box"
    t.integer  "male_female",         :limit => 2
    t.boolean  "trouble_red_green"
    t.boolean  "trouble_blue_yellow"
    t.integer  "age"
    t.string   "word"
    t.datetime "created_at"
  end

  add_index "color_blindness_tests", ["worker_id"], :name => "index_color_blindness_tests_on_worker_id", :unique => true

  create_table "cron_jobs", :force => true do |t|
    t.string   "name"
    t.text     "data"
    t.datetime "created_at"
  end

  create_table "db_admins", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "db_admins", ["email"], :name => "index_db_admins_on_email", :unique => true
  add_index "db_admins", ["reset_password_token"], :name => "index_db_admins_on_reset_password_token", :unique => true

  create_table "disqualified_workers", :force => true do |t|
    t.string   "mturk_worker_id"
    t.datetime "created_at"
  end

  add_index "disqualified_workers", ["mturk_worker_id"], :name => "index_disqualified_workers_on_mturk_worker_id", :unique => true

  create_table "disqualify_data_from_workers", :force => true do |t|
    t.string   "mturk_worker_id"
    t.text     "reason"
    t.datetime "created_at"
    t.integer  "level",           :limit => 2, :default => 1
    t.string   "error_code"
    t.integer  "user_id"
  end

  add_index "disqualify_data_from_workers", ["mturk_worker_id"], :name => "index_disqualify_data_from_workers_on_mturk_worker_id", :unique => true

  create_table "identifications", :force => true do |t|
    t.integer  "worker_id"
    t.integer  "image_id"
    t.float    "wage"
    t.integer  "set_number",      :limit => 2
    t.text     "points"
    t.text     "log"
    t.float    "precision"
    t.float    "recall"
    t.datetime "started_at"
    t.datetime "submitted_at"
    t.datetime "created_at"
    t.boolean  "accurate_enough"
  end

  add_index "identifications", ["worker_id"], :name => "index_identifications_on_worker_id"

  create_table "images", :force => true do |t|
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "phenotype_id"
    t.integer  "order",        :limit => 2
    t.text     "truth_points"
    t.datetime "created_at"
    t.string   "image"
  end

  add_index "images", ["order"], :name => "index_images_on_order"

  create_table "m_hit_views", :force => true do |t|
    t.integer  "m_hit_id"
    t.string   "ip_address"
    t.datetime "created_at"
  end

  add_index "m_hit_views", ["ip_address"], :name => "index_m_hit_views_on_ip_address"
  add_index "m_hit_views", ["m_hit_id"], :name => "index_m_hit_views_on_m_hit_id"

  create_table "m_hits", :force => true do |t|
    t.string   "mturk_hit_id"
    t.string   "mturk_group_id"
    t.integer  "experimental_country",    :limit => 2
    t.text     "wage_schedule"
    t.string   "current_mturk_worker_id"
    t.integer  "version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "expire_at"
  end

  add_index "m_hits", ["mturk_hit_id"], :name => "index_m_hits_on_mturk_hit_id"

  create_table "payment_outcomes", :force => true do |t|
    t.integer  "worker_id"
    t.boolean  "rejected",                             :default => false, :null => false
    t.boolean  "accepted",                             :default => true,  :null => false
    t.boolean  "never_submitted_therefore_never_paid", :default => false, :null => false
    t.float    "total_payout",                         :default => 0.0,   :null => false
    t.datetime "created_at"
  end

  add_index "payment_outcomes", ["worker_id"], :name => "index_payment_outcomes_on_worker_id", :unique => true

  create_table "phenotypes", :force => true do |t|
    t.string   "name"
    t.integer  "hit_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phenotype"
  end

  create_table "project_params", :force => true do |t|
    t.integer  "num_images",             :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_version_number", :limit => 2, :default => 2, :null => false
  end

  create_table "qualifications", :force => true do |t|
    t.integer  "worker_id"
    t.datetime "created_at"
  end

  add_index "qualifications", ["worker_id"], :name => "index_qualifications_on_worker_id", :unique => true

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "rounded_corners", :force => true do |t|
    t.integer  "radius"
    t.string   "border"
    t.string   "interior"
    t.datetime "created_at"
  end

  add_index "rounded_corners", ["radius"], :name => "index_rounded_corners_on_radius"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "video_watchings", :force => true do |t|
    t.integer  "worker_id"
    t.datetime "created_at"
    t.float    "elapsed"
    t.string   "event_type"
  end

  add_index "video_watchings", ["worker_id"], :name => "index_video_watchings_on_worker_id"

  create_table "want_to_leaves", :force => true do |t|
    t.integer  "worker_id"
    t.datetime "created_at"
  end

  add_index "want_to_leaves", ["worker_id"], :name => "index_want_to_leaves_on_worker_id"

  create_table "worker_admin_comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "worker_id"
    t.text     "body"
    t.datetime "created_at"
  end

  add_index "worker_admin_comments", ["worker_id"], :name => "index_worker_admin_comments_on_worker_id"

  create_table "worker_comments", :force => true do |t|
    t.integer  "hit_id"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worker_surveys", :force => true do |t|
    t.integer  "worker_id"
    t.integer  "enjoyment",      :limit => 1
    t.integer  "purpose",        :limit => 1
    t.integer  "accomplishment", :limit => 1
    t.integer  "meaningful",     :limit => 1
    t.integer  "recognition",    :limit => 1
    t.text     "comments"
    t.datetime "finished_at"
    t.datetime "created_at"
  end

  create_table "workers", :force => true do |t|
    t.integer  "m_hit_id"
    t.string   "mturk_worker_id"
    t.string   "mturk_assignment_id"
    t.string   "ip_address"
    t.datetime "finished_at"
    t.datetime "created_at"
    t.datetime "manually_checked_over"
    t.string   "experimental_group"
    t.boolean  "warning_page_seen",     :default => false, :null => false
    t.text     "image_order"
    t.datetime "debriefed_at"
  end

  add_index "workers", ["m_hit_id"], :name => "index_workers_on_m_hit_id"
  add_index "workers", ["mturk_worker_id"], :name => "index_workers_on_mturk_worker_id"

end
