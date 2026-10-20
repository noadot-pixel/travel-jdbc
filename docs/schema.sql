-- ============================================================
-- trable-jdbc Oracle schema
-- Matches the SQL that the DAO classes in the model package run, 1:1.
-- Run this file top to bottom, as-is, logged in as the app's DB user (e.g. "travel").
--
-- NOTE ON ENCODING: comments in this file are kept in plain ASCII on purpose.
-- Korean comments here previously caused SQL*Plus (on a Windows client whose
-- NLS_LANG didn't match the file's UTF-8 encoding) to silently misparse a
-- line and DROP the next column definition -- no error was printed, the
-- CREATE TABLE just "succeeded" with one column missing (MEMBERS.REAL_NAME).
-- If you want to add your own Korean comments, first run (in the same
-- session, before this script):  SET SQLPROMPT ""  and make sure your
-- Windows console codepage / NLS_LANG matches the file's encoding --
-- otherwise verify with DESC <table> afterwards that every column exists.
-- ============================================================

-- 1. Members
-- id = login id = email address. The signup/login screens only ask for one
-- "email" field, so that value is used directly as the primary key instead
-- of adding a separate "id" field (see MemberDTO's class comment).
CREATE TABLE members (
    id               VARCHAR2(100)  PRIMARY KEY,
    pwd              VARCHAR2(100)  NOT NULL,
    nickname         VARCHAR2(30)   NOT NULL,
    admin_level      NUMBER         DEFAULT 0 NOT NULL,   -- 0 = regular member, 1 = moderator, 2 = admin
    join_date        DATE           DEFAULT SYSDATE NOT NULL,
    bio              VARCHAR2(500),
    country          VARCHAR2(10),                -- KR / JP / ETC
    country_other    VARCHAR2(50),                -- free-text value when country = ETC
    real_name        VARCHAR2(50),
    name_public      CHAR(1)        DEFAULT 'Y' NOT NULL,
    photo_path       VARCHAR2(300),
    gender           VARCHAR2(1),                 -- M / F, asked at signup (ranking feature). NULL for members who joined before this.
    gender_public    CHAR(1)        DEFAULT 'Y' NOT NULL,
    last_notice_seen DATE,                        -- last time this member opened the notification bell. NULL = never.
    suspended        CHAR(1)        DEFAULT 'N' NOT NULL,  -- admin-set; blocks comment/like/post-write, not scraps
    dark_mode        CHAR(1)        DEFAULT 'N' NOT NULL   -- self-set in mypage; applied to every page via <html data-theme>
);

-- birthday/birthday_public columns existed briefly (mypage personal-info section) and
-- were dropped - the feature was removed, not just hidden, so there is nothing left that
-- reads or writes them.
-- (NOTE: this comment must stay OUTSIDE the CREATE TABLE parens above - a trailing
-- comment-only block right before a closing ")" makes SQL*Plus misparse the next
-- line as a stray command, "SP2-0042: unknown command ")" ". Verified by reproducing
-- it in isolation while debugging this exact file.)

-- Make an account a moderator or admin (sign up through the normal form first, then run):
-- UPDATE members SET admin_level = 1 WHERE id = 'the email you signed up with';  -- moderator
-- UPDATE members SET admin_level = 2 WHERE id = 'the email you signed up with';  -- admin
-- COMMIT;
-- After the first admin exists, everyone else can instead be promoted from
-- /admin/members (only an admin, level 2, can change another account's level).


-- 2. Posts
CREATE SEQUENCE seq_posts START WITH 1 INCREMENT BY 1;

CREATE TABLE posts (
    bno         NUMBER          PRIMARY KEY,
    writer      VARCHAR2(100)   NOT NULL REFERENCES members(id),
    title       VARCHAR2(200)   NOT NULL,
    content     CLOB            NOT NULL,          -- was VARCHAR2(4000); moved to CLOB to fit rich-text/HTML post bodies
    country     VARCHAR2(3)     NOT NULL,          -- KR / JP / ETC
    region      VARCHAR2(30),                      -- country=KR/JP일 때만 필수(세부 지역). ETC는 NULL.
                                                     -- KR_CAPITAL/KR_GANGWON/KR_CHUNGCHEONG/KR_JEOLLA/KR_GYEONGSANG/KR_JEJU
                                                     -- JP_HOKKAIDO/JP_TOHOKU/JP_KANTO/JP_CHUBU/JP_KANSAI/JP_CHUGOKU/JP_SHIKOKU/JP_KYUSHU_OKINAWA
    style       VARCHAR2(10)    NOT NULL,          -- healing / food / activity / shopping
    img_path    VARCHAR2(300),                     -- "images/korea.jpg" (default) or "upload/post/xxx.jpg" (uploaded)
    view_cnt    NUMBER          DEFAULT 0 NOT NULL,
    like_cnt    NUMBER          DEFAULT 0 NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    mod_date    DATE
);


-- 3. Comments (cascades when the post is deleted)
CREATE SEQUENCE seq_comments START WITH 1 INCREMENT BY 1;

CREATE TABLE comments (
    cno         NUMBER          PRIMARY KEY,
    bno         NUMBER          NOT NULL REFERENCES posts(bno) ON DELETE CASCADE,
    writer      VARCHAR2(100)   NOT NULL REFERENCES members(id),
    content     VARCHAR2(500)   NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL
);


-- 4. Likes (one member can like a post at most once -- the (bno, member_id)
-- primary key enforces that)
CREATE TABLE post_likes (
    bno         NUMBER          NOT NULL REFERENCES posts(bno) ON DELETE CASCADE,
    member_id   VARCHAR2(100)   NOT NULL REFERENCES members(id),
    like_date   DATE            DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY (bno, member_id)
);


-- 5. Scraps (bookmarks)
CREATE TABLE scraps (
    member_id    VARCHAR2(100)  NOT NULL REFERENCES members(id),
    bno          NUMBER         NOT NULL REFERENCES posts(bno) ON DELETE CASCADE,
    scrap_date   DATE           DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY (member_id, bno)
);


-- 6. Post action log (admin screen). No FK on bno -- a deleted post's log
-- entries must stay, so post_title is copied in at the time of the action
-- instead of being looked up later.
CREATE SEQUENCE seq_post_logs START WITH 1 INCREMENT BY 1;

CREATE TABLE post_logs (
    log_id      NUMBER          PRIMARY KEY,
    log_type    VARCHAR2(10)    NOT NULL,          -- CREATE / UPDATE / DELETE
    bno         NUMBER          NOT NULL,
    post_title  VARCHAR2(200)   NOT NULL,
    actor_id    VARCHAR2(100)   NOT NULL REFERENCES members(id),
    log_date    DATE            DEFAULT SYSDATE NOT NULL
);


-- 7. Notices (admin announcements, shown in every member's notification bell)
CREATE SEQUENCE seq_notices START WITH 1 INCREMENT BY 1;

CREATE TABLE notices (
    notice_id   NUMBER          PRIMARY KEY,
    title       VARCHAR2(200)   NOT NULL,
    content     VARCHAR2(2000)  NOT NULL,
    writer      VARCHAR2(100)   NOT NULL REFERENCES members(id),   -- admin who wrote it
    reg_date    DATE            DEFAULT SYSDATE NOT NULL
);


-- 8. FAQs (footer "자주 묻는 질문", editable by admins on /admin/faqs)
CREATE SEQUENCE seq_faqs START WITH 1 INCREMENT BY 1;

CREATE TABLE faqs (
    faq_id      NUMBER          PRIMARY KEY,
    question    VARCHAR2(300)   NOT NULL,
    answer      VARCHAR2(2000)  NOT NULL,
    writer      VARCHAR2(100)   NOT NULL REFERENCES members(id),
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    mod_date    DATE
);


-- 9. Inquiries (footer "문의하기" board - anyone can read, members can post)
CREATE SEQUENCE seq_inquiries START WITH 1 INCREMENT BY 1;

CREATE TABLE inquiries (
    inquiry_id        NUMBER          PRIMARY KEY,
    title             VARCHAR2(200)   NOT NULL,
    content           VARCHAR2(2000)  NOT NULL,
    writer            VARCHAR2(100)   NOT NULL REFERENCES members(id),
    reg_date          DATE            DEFAULT SYSDATE NOT NULL,
    is_private        CHAR(1)         DEFAULT 'N' NOT NULL  -- 'Y'면 작성자 본인과 관리자만 볼 수 있음
);

-- 9-1. Inquiry comments (상세 페이지의 댓글 - 문의 당사자와 moderator 이상만 남길 수 있다,
-- Command에서 검사함. 게시글 댓글(COMMENTS)과 달리 전체 공개 댓글이 아니라서 별도 테이블로 둔다)
CREATE SEQUENCE seq_inquiry_comments START WITH 1 INCREMENT BY 1;

CREATE TABLE inquiry_comments (
    inquiry_comment_id  NUMBER          PRIMARY KEY,
    inquiry_id          NUMBER          NOT NULL REFERENCES inquiries(inquiry_id) ON DELETE CASCADE,
    writer              VARCHAR2(100)   NOT NULL REFERENCES members(id),
    content             VARCHAR2(1000)  NOT NULL,
    reg_date            DATE            DEFAULT SYSDATE NOT NULL
);


-- 10. Notifications (personal alerts - someone commented/liked my post, or
-- commented on an inquiry I'm involved in). Must come after inquiries (table 9)
-- since it has a foreign key to it.
CREATE SEQUENCE seq_notifications START WITH 1 INCREMENT BY 1;

CREATE TABLE notifications (
    notif_id    NUMBER          PRIMARY KEY,
    member_id   VARCHAR2(100)   NOT NULL REFERENCES members(id),              -- who the alert is for
    type        VARCHAR2(20)    NOT NULL,                                     -- COMMENT / LIKE / INQUIRY_COMMENT
    target_type VARCHAR2(10)    DEFAULT 'POST' NOT NULL,                      -- POST / INQUIRY - which of bno/inquiry_id is set
    bno         NUMBER          REFERENCES posts(bno) ON DELETE CASCADE,      -- set when target_type = POST
    inquiry_id  NUMBER          REFERENCES inquiries(inquiry_id) ON DELETE CASCADE, -- set when target_type = INQUIRY
    actor_id    VARCHAR2(100)   NOT NULL REFERENCES members(id),              -- who commented/liked
    is_read     CHAR(1)         DEFAULT 'N' NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL
);
