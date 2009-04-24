CREATE TABLE "application"
(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "name" TEXT,
    "company" TEXT,
    "app_identifier" TEXT NOT NULL,
    "default_store_identifier" TEXT NOT NULL,
	"position" INTEGER DEFAULT -1
);

CREATE TABLE "application_details"
(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "app_identifier" TEXT,
    "store_identifier" TEXT,
    "name" TEXT,
    "company" TEXT,
    "category" TEXT,
    "category_identifier" TEXT,
    "released" TEXT,
    "version" TEXT,
    "size" TEXT,
    "price" TEXT,
    "rating_count_all" INTEGER DEFAULT 0,
    "rating_count_all_5stars" INTEGER DEFAULT 0,
    "rating_count_all_4stars" INTEGER DEFAULT 0,
    "rating_count_all_3stars" INTEGER DEFAULT 0,
    "rating_count_all_2stars" INTEGER DEFAULT 0,
    "rating_count_all_1star" INTEGER DEFAULT 0,
    "rating_all" REAL DEFAULT 0,
    "review_count_all" INTEGER DEFAULT 0,
    "rating_count_current" INTEGER DEFAULT 0,
    "rating_count_current_5stars" INTEGER DEFAULT 0,
    "rating_count_current_4stars" INTEGER DEFAULT 0,
    "rating_count_current_3stars" INTEGER DEFAULT 0,
    "rating_count_current_2stars" INTEGER DEFAULT 0,
    "rating_count_current_1star" INTEGER DEFAULT 0,
    "rating_current" REAL DEFAULT 0,
    "review_count_current" INTEGER DEFAULT 0,
	"company_url" TEXT,
	"company_url_title" TEXT,
	"support_url" TEXT,
	"support_url_title" TEXT,
    "last_sort_order" INTEGER,
    "last_updated" DATETIME
);

CREATE TABLE "application_review"
(
    "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    "app_identifier" TEXT,
    "store_identifier" TEXT,
    "reviewer" TEXT,
    "rating" REAL,
    "summary" TEXT,
    "detail" TEXT,
    "app_version" TEXT,
    "review_date" TEXT,
    "review_index" INTEGER
);
