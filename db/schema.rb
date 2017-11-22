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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171122175807) do

  create_table "assignment_submissions", force: :cascade do |t|
    t.integer  "enrolment_id",            limit: 4,                        null: false
    t.string   "title",                   limit: 255,                      null: false
    t.text     "summary",                 limit: 65535
    t.text     "description",             limit: 16777215
    t.boolean  "completed",                                default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scheduled_assignment_id", limit: 4,                        null: false
    t.text     "rearrangement",           limit: 65535
  end

  add_index "assignment_submissions", ["enrolment_id"], name: "idx_enrolment_id", using: :btree
  add_index "assignment_submissions", ["scheduled_assignment_id", "enrolment_id"], name: "idx_scheduled_assignment_id", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.integer  "lesson_id",    limit: 4,                    null: false
    t.string   "title",        limit: 255,                  null: false
    t.text     "summary",      limit: 65535
    t.text     "description",  limit: 16777215
    t.integer  "duration",     limit: 4,        default: 0, null: false
    t.integer  "starts_after", limit: 2,        default: 1, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["lesson_id"], name: "idx_lesson_id", using: :btree

  create_table "attachments", force: :cascade do |t|
    t.integer  "owner_user_id",      limit: 4,                      null: false
    t.integer  "attachable_id",      limit: 4,                      null: false
    t.string   "attachable_type",    limit: 255,                    null: false
    t.string   "title",              limit: 255
    t.text     "description",        limit: 16777215
    t.integer  "position",           limit: 4,        default: 0,   null: false
    t.string   "asset_file_name",    limit: 255
    t.string   "asset_content_type", limit: 255
    t.integer  "asset_file_size",    limit: 4
    t.datetime "asset_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",             limit: 1,        default: "n", null: false
    t.string   "asset_orientation",  limit: 9
    t.text     "meta_data",          limit: 65535
    t.string   "vimeo_video_id",     limit: 255
    t.string   "youtube_video_id",   limit: 255
  end

  add_index "attachments", ["attachable_type", "attachable_id"], name: "idx_attachable_type_attachable_id", using: :btree
  add_index "attachments", ["owner_user_id"], name: "idx_owner_user_id", using: :btree
  add_index "attachments", ["position"], name: "idx_position", using: :btree
  add_index "attachments", ["status"], name: "idx_status", using: :btree

  create_table "banner_images", force: :cascade do |t|
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",               limit: 255, null: false
  end

  create_table "blog_posts", force: :cascade do |t|
    t.string   "title",      limit: 1024
    t.string   "url",        limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "course_types", force: :cascade do |t|
    t.string   "title",                   limit: 255,   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "homepage_description",    limit: 255
    t.string   "course_page_title",       limit: 255
    t.text     "course_page_description", limit: 65535
    t.integer  "number",                  limit: 4
  end

  create_table "courses", force: :cascade do |t|
    t.string   "title",              limit: 255,                      null: false
    t.text     "summary",            limit: 65535
    t.text     "description",        limit: 16777215
    t.integer  "price_in_cents",     limit: 4,        default: 0,     null: false
    t.date     "starts_on",                                           null: false
    t.integer  "frequency",          limit: 2,                        null: false
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "price_currency",     limit: 3,        default: "USD", null: false
    t.boolean  "available",                           default: true,  null: false
    t.string   "page_title",         limit: 255
    t.boolean  "instant_access",                      default: false
    t.boolean  "hidden",                              default: false
    t.text     "meta_description",   limit: 65535
    t.text     "meta_keywords",      limit: 65535
    t.boolean  "hide_dates",                          default: false
    t.integer  "course_type_id",     limit: 4
    t.boolean  "portfolio_review",                    default: false
    t.string   "youtube_video_id",   limit: 255
    t.string   "vimeo_video_id",     limit: 255
    t.boolean  "category_1",                          default: false
    t.boolean  "category_2",                          default: false
    t.boolean  "category_3",                          default: false
    t.boolean  "category_4",                          default: false
    t.boolean  "category_5",                          default: false
    t.integer  "duration",           limit: 4
    t.integer  "fee_price_in_cents", limit: 4
  end

  create_table "critiques", force: :cascade do |t|
    t.integer  "critiqueable_id",        limit: 4,        null: false
    t.string   "critiqueable_type",      limit: 255,      null: false
    t.integer  "user_id",                limit: 4,        null: false
    t.text     "comment",                limit: 16777215
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original_sequence",      limit: 255
    t.string   "rearrangement_sequence", limit: 255
  end

  create_table "enquiries", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "phone_number", limit: 255
    t.string   "email",        limit: 255
    t.text     "message",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "enrolments", force: :cascade do |t|
    t.integer  "scheduled_course_id", limit: 4,                                null: false
    t.integer  "student_user_id",     limit: 4,                                null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_id",         limit: 4
    t.integer  "package_purchase_id", limit: 4
    t.datetime "end_date"
    t.boolean  "unsubscribe",                                  default: false
    t.decimal  "fees",                          precision: 10
    t.integer  "duration",            limit: 4
    t.integer  "parent_id",           limit: 4
    t.integer  "enrolment_type",      limit: 4,                default: 0
  end

  add_index "enrolments", ["purchase_id"], name: "idx_purchase_id", using: :btree
  add_index "enrolments", ["scheduled_course_id", "student_user_id"], name: "idx_scheduled_course_id_student_user_id", using: :btree
  add_index "enrolments", ["scheduled_course_id"], name: "idx_scheduled_course_id", using: :btree

  create_table "exchange_rates", force: :cascade do |t|
    t.string   "base_currency",    limit: 3,                                        null: false
    t.string   "counter_currency", limit: 3,                                        null: false
    t.decimal  "rate",                       precision: 10, scale: 4, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exchange_rates", ["base_currency", "counter_currency"], name: "idx_base_currency_counter_currency", unique: true, using: :btree

  create_table "forum_posts", force: :cascade do |t|
    t.integer  "user_id",        limit: 4,        null: false
    t.integer  "forum_topic_id", limit: 4,        null: false
    t.text     "content",        limit: 16777215
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_posts", ["forum_topic_id"], name: "idx_forum_topic_id", using: :btree
  add_index "forum_posts", ["user_id"], name: "idx_user_id", using: :btree

  create_table "forum_topic_users", force: :cascade do |t|
    t.integer  "user_id",        limit: 4, null: false
    t.integer  "forum_topic_id", limit: 4, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_topic_users", ["forum_topic_id"], name: "idx_forum_topic_id", using: :btree
  add_index "forum_topic_users", ["user_id"], name: "idx_user_id", using: :btree

  create_table "forum_topics", force: :cascade do |t|
    t.integer  "user_id",          limit: 4,                    null: false
    t.integer  "discussable_id",   limit: 4
    t.string   "discussable_type", limit: 255
    t.string   "title",            limit: 255,                  null: false
    t.text     "content",          limit: 16777215
    t.integer  "posts_count",      limit: 4,        default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "publish_on",                                    null: false
  end

  add_index "forum_topics", ["discussable_type", "discussable_id"], name: "idx_discussable_type_discussable_id", using: :btree
  add_index "forum_topics", ["user_id"], name: "idx_user_id", using: :btree

  create_table "gifts", force: :cascade do |t|
    t.integer  "lessons_amount", limit: 4,                     null: false
    t.integer  "price_in_cents", limit: 4,                     null: false
    t.text     "description",    limit: 65535
    t.string   "title",          limit: 255,                   null: false
    t.integer  "category",       limit: 4,                     null: false
    t.integer  "course_id",      limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "with_skype",                   default: false
  end

  create_table "instructorships", force: :cascade do |t|
    t.integer  "course_id",          limit: 4, null: false
    t.integer  "instructor_user_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "instructorships", ["course_id", "instructor_user_id"], name: "idx_course_id_instructor_user_id", unique: true, using: :btree
  add_index "instructorships", ["course_id"], name: "idx_course_id", using: :btree

  create_table "lessons", force: :cascade do |t|
    t.integer  "course_id",          limit: 4,                    null: false
    t.string   "title",              limit: 255,                  null: false
    t.text     "summary",            limit: 65535
    t.text     "description",        limit: 16777215
    t.integer  "duration",           limit: 4,        default: 0, null: false
    t.integer  "position",           limit: 4,        default: 0, null: false
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lessons", ["course_id"], name: "idx_course_id", using: :btree
  add_index "lessons", ["position"], name: "idx_position", using: :btree

  create_table "package_courses", force: :cascade do |t|
    t.integer  "package_id", limit: 4
    t.integer  "course_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "package_purchases", force: :cascade do |t|
    t.integer  "package_id",               limit: 4,     default: 0,         null: false
    t.integer  "student_user_id",          limit: 4,     default: 0,         null: false
    t.integer  "price_in_cents",           limit: 4,     default: 0,         null: false
    t.string   "price_currency",           limit: 3,     default: "USD",     null: false
    t.string   "gateway",                  limit: 50,    default: "",        null: false
    t.string   "reference",                limit: 255
    t.string   "status",                   limit: 255,   default: "pending", null: false
    t.text     "raw_params",               limit: 65535
    t.datetime "notification_received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", force: :cascade do |t|
    t.string   "title",              limit: 255,                      null: false
    t.string   "page_title",         limit: 255
    t.text     "summary",            limit: 65535
    t.text     "description",        limit: 16777215
    t.integer  "price_in_cents",     limit: 4,        default: 0,     null: false
    t.string   "price_currency",     limit: 3,        default: "USD", null: false
    t.string   "photo_file_name",    limit: 255
    t.string   "photo_content_type", limit: 255
    t.integer  "photo_file_size",    limit: 4
    t.datetime "photo_updated_at"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partners", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "url",         limit: 255
    t.text     "description", limit: 65535,              null: false
    t.string   "logo",        limit: 255,   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "scheduled_course_id",      limit: 4,                         null: false
    t.integer  "student_user_id",          limit: 4,                         null: false
    t.integer  "price_in_cents",           limit: 4,                         null: false
    t.string   "price_currency",           limit: 3,     default: "USD",     null: false
    t.string   "gateway",                  limit: 50,                        null: false
    t.string   "reference",                limit: 255
    t.string   "status",                   limit: 255,   default: "pending", null: false
    t.text     "raw_params",               limit: 65535
    t.datetime "notification_received_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_id",               limit: 255
  end

  add_index "purchases", ["scheduled_course_id", "student_user_id"], name: "idx_scheduled_course_id_student_user_id", using: :btree
  add_index "purchases", ["scheduled_course_id"], name: "idx_scheduled_course_id", using: :btree
  add_index "purchases", ["status"], name: "idx_status", using: :btree

  create_table "rearrangements", force: :cascade do |t|
    t.integer  "assignment_id", limit: 4,     null: false
    t.string   "title",         limit: 255,   null: false
    t.text     "summary",       limit: 65535
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "renewals", force: :cascade do |t|
    t.integer  "duration",       limit: 4
    t.integer  "amount",         limit: 4
    t.integer  "course_id",      limit: 4,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "price_in_cents", limit: 4, default: 0,     null: false
    t.string   "price_currency", limit: 3, default: "USD", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.text     "content",         limit: 65535
    t.integer  "student_user_id", limit: 4
    t.integer  "course_id",       limit: 4
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reviews", ["course_id"], name: "index_reviews_on_course_id", using: :btree
  add_index "reviews", ["student_user_id"], name: "index_reviews_on_student_user_id", using: :btree

  create_table "scheduled_assignments", force: :cascade do |t|
    t.integer  "scheduled_lesson_id", limit: 4, null: false
    t.integer  "assignment_id",       limit: 4, null: false
    t.date     "starts_on"
    t.date     "ends_on"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scheduled_assignments", ["assignment_id", "scheduled_lesson_id"], name: "idx_assignment_id_scheduled_lesson_id", unique: true, using: :btree
  add_index "scheduled_assignments", ["scheduled_lesson_id"], name: "idx_scheduled_lesson_id", using: :btree

  create_table "scheduled_courses", force: :cascade do |t|
    t.integer  "course_id",  limit: 4,                 null: false
    t.date     "starts_on"
    t.date     "ends_on"
    t.boolean  "system",               default: false, null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "duration",   limit: 4
  end

  add_index "scheduled_courses", ["course_id"], name: "course_id", using: :btree

  create_table "scheduled_lessons", force: :cascade do |t|
    t.integer  "scheduled_course_id", limit: 4, null: false
    t.integer  "lesson_id",           limit: 4, null: false
    t.date     "starts_on"
    t.date     "ends_on"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "student_user_id",     limit: 4
    t.integer  "enrolment_id",        limit: 4
  end

  add_index "scheduled_lessons", ["scheduled_course_id"], name: "idx_scheduled_course_id", using: :btree
  add_index "scheduled_lessons", ["student_user_id"], name: "index_scheduled_lessons_on_student_user_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "value",      limit: 255
    t.string   "method",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "other",      limit: 255
  end

  create_table "student_galleries", force: :cascade do |t|
    t.string   "creator",            limit: 255
    t.string   "course",             limit: 255
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id",        limit: 4
    t.integer "taggable_id",   limit: 4
    t.string  "taggable_type", limit: 255
    t.integer "user_id",       limit: 4
    t.string  "context",       limit: 128
    t.integer "tagger_id",     limit: 4
    t.string  "tagger_type",   limit: 255
  end

  add_index "taggings", ["tag_id", "taggable_type"], name: "idx_tag_id_taggable_type", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["taggable_id", "taggable_type"], name: "idx_taggable_id_taggable_type", using: :btree
  add_index "taggings", ["user_id", "tag_id", "taggable_type"], name: "idx_user_id_tag_id_taggable_type", using: :btree
  add_index "taggings", ["user_id", "taggable_id", "taggable_type"], name: "idx_user_id_taggable_id_taggable_type", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0, null: false
  end

  add_index "tags", ["name"], name: "idx_name", using: :btree
  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree
  add_index "tags", ["taggings_count"], name: "idx_taggings_count", using: :btree

  create_table "testimonials", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "content",    limit: 65535
    t.string   "logo",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_gifts", force: :cascade do |t|
    t.integer  "gift_id",         limit: 4,                          null: false
    t.string   "recipient_email", limit: 255,                        null: false
    t.string   "recipient_name",  limit: 255,                        null: false
    t.boolean  "is_used",                     default: false
    t.integer  "status",          limit: 4,   default: 0
    t.integer  "coupon_code",     limit: 4,                          null: false
    t.date     "notify_on",                   default: '2017-11-21'
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                         limit: 320,                         null: false
    t.string   "password_hash",                 limit: 64,                          null: false
    t.string   "password_salt",                 limit: 64,                          null: false
    t.string   "role",                          limit: 1,        default: "s",      null: false
    t.string   "given_name",                    limit: 255,                         null: false
    t.string   "family_name",                   limit: 255,                         null: false
    t.string   "address_street",                limit: 255
    t.string   "address_locality",              limit: 255
    t.string   "address_region",                limit: 255
    t.string   "address_postal_code",           limit: 20
    t.string   "address_country",               limit: 2
    t.string   "phone_voice",                   limit: 50
    t.string   "phone_mobile",                  limit: 50
    t.text     "profile",                       limit: 16777215
    t.string   "time_zone",                     limit: 30,       default: "London", null: false
    t.string   "activation_code",               limit: 8
    t.string   "temporary_password",            limit: 255
    t.datetime "temporary_password_expires_at"
    t.string   "status",                        limit: 15,                          null: false
    t.datetime "last_seen_at"
    t.string   "photo_file_name",               limit: 255
    t.string   "photo_content_type",            limit: 255
    t.integer  "photo_file_size",               limit: 4
    t.datetime "photo_updated_at"
    t.string   "instructor_photo_file_name",    limit: 255
    t.string   "instructor_photo_content_type", limit: 255
    t.integer  "instructor_photo_file_size",    limit: 4
    t.datetime "instructor_photo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "hidden",                                         default: false
    t.text     "meta_description",              limit: 65535
    t.text     "meta_keywords",                 limit: 65535
    t.boolean  "mentor"
    t.string   "youtube_video_id",              limit: 255,      default: "",       null: false
    t.string   "vimeo_video_id",                limit: 255,      default: "",       null: false
    t.string   "uid",                           limit: 255
    t.text     "custom_video_code",             limit: 65535
  end

  add_index "users", ["email"], name: "idx_email", length: {"email"=>100}, using: :btree

  create_table "workshops", force: :cascade do |t|
    t.string   "title",                  limit: 255,                      null: false
    t.string   "page_title",             limit: 255
    t.text     "summary",                limit: 65535
    t.text     "description",            limit: 16777215
    t.text     "enrolment",              limit: 65535
    t.text     "upcoming",               limit: 65535
    t.text     "terms",                  limit: 65535
    t.integer  "full_price_in_cents",    limit: 4,        default: 0,     null: false
    t.string   "full_price_currency",    limit: 3,        default: "USD", null: false
    t.integer  "deposit_price_in_cents", limit: 4,        default: 0,     null: false
    t.string   "deposit_price_currency", limit: 3,        default: "USD", null: false
    t.string   "photo_1_file_name",      limit: 255
    t.string   "photo_1_content_type",   limit: 255
    t.integer  "photo_1_file_size",      limit: 4
    t.datetime "photo_1_updated_at"
    t.string   "photo_2_file_name",      limit: 255
    t.string   "photo_2_content_type",   limit: 255
    t.integer  "photo_2_file_size",      limit: 4
    t.datetime "photo_2_updated_at"
    t.string   "photo_3_file_name",      limit: 255
    t.string   "photo_3_content_type",   limit: 255
    t.integer  "photo_3_file_size",      limit: 4
    t.datetime "photo_3_updated_at"
    t.string   "photo_4_file_name",      limit: 255
    t.string   "photo_4_content_type",   limit: 255
    t.integer  "photo_4_file_size",      limit: 4
    t.datetime "photo_4_updated_at"
    t.string   "photo_5_file_name",      limit: 255
    t.string   "photo_5_content_type",   limit: 255
    t.integer  "photo_5_file_size",      limit: 4
    t.datetime "photo_5_updated_at"
    t.string   "photo_6_file_name",      limit: 255
    t.string   "photo_6_content_type",   limit: 255
    t.integer  "photo_6_file_size",      limit: 4
    t.datetime "photo_6_updated_at"
    t.string   "vimeo_video_id",         limit: 255
    t.integer  "instructor_1_id",        limit: 4
    t.integer  "instructor_2_id",        limit: 4
    t.integer  "instructor_3_id",        limit: 4
    t.integer  "instructor_4_id",        limit: 4
    t.boolean  "visible"
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "youtube_video_id",       limit: 255
  end

end
