
-- Scheme for Geocube

create table config (
    id integer primary key,
    key text,
    value text
);
create index config_idx_key on config(key);
insert into config(key, value) values("url_sites", "https://geocube.mavetju.org/geocube_sites.geocube");
insert into config(key, value) values("url_notices", "https://geocube.mavetju.org/geocube_notices.geocube");
insert into config(key, value) values("url_externalmaps", "https://geocube.mavetju.org/geocube_externalmaps.geocube");
insert into config(key, value) values("url_countries", "https://geocube.mavetju.org/geocube_externalmaps.geocube");
insert into config(key, value) values("url_states", "https://geocube.mavetju.org/geocube_externalmaps.geocube");
insert into config(key, value) values("url_attributes", "https://geocube.mavetju.org/geocube_externalmaps.geocube");
insert into config(key, value) values("url_keys", "https://geocube.mavetju.org/geocube_keys.geocube");
insert into config(key, value) values("version", "18");

create table filters (
    id integer primary key,
    key text,
    value text
);
create index filters_idx_key on filters(key);

create table groups (
    id integer primary key,
    usergroup bool,
    deletable bool,
    name text
);
create index groups_idx_id on groups(id);
insert into groups(name, usergroup, deletable) values("All Waypoints", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Found", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Attended", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Not Found", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Manually entered", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Ignored", 0, 0);
insert into groups(name, usergroup, deletable) values("Last Import", 0, 0);
insert into groups(name, usergroup, deletable) values("Last Import - New", 0, 0);
insert into groups(name, usergroup, deletable) values("Live Import", 1, 0);
insert into groups(name, usergroup, deletable) values("GCA - NSW", 1, 1);
insert into groups(name, usergroup, deletable) values("GC - NSW", 1, 1);
insert into groups(name, usergroup, deletable) values("GC - ACT", 1, 1);

create table group2waypoints (
    id integer primary key,
    waypoint_id integer,		-- points to waypoints(id)
    group_id integer			-- points to groups(id)
);
create index group2waypoints_idx_group_id on group2waypoints(group_id);
create index group2waypoints_idx_waypoint_id on group2waypoints(waypoint_id);

create table waypoints (
    id integer primary key,
    wpt_lat text,
    wpt_lon text,
    wpt_lat_int integer,		-- lat times 1000 000 for now
    wpt_lon_int integer,		-- lon times 1000 000 for now
    wpt_name text,
    wpt_description text,
    wpt_date_placed string,
    wpt_date_placed_epoch integer,
    wpt_url text,
    wpt_urlname text,
    wpt_symbol_id integer,		-- pointer to symbols(id)
    wpt_type_id integer,		-- pointer to types(id)

    account_id integer,			-- pointer to accounts(id)
    log_status integer,			-- 0 not logged, 1 DNF, 2 found
    highlight bool,
    ignore bool,
    markedfound bool,
    inprogress bool,
    dnfed bool,

    gs_enabled bool,
    gs_archived bool,
    gs_available bool,
    gs_country_id integer,		-- pointer to countries(id)
    gs_state_id integer,		-- pointer to states(id)
    gs_rating_difficulty float,
    gs_rating_terrain float,
    gs_date_found integer,
    gs_favourites integer,
    gs_long_desc_html bool,
    gs_long_desc text,
    gs_short_desc_html bool,
    gs_short_desc text,
    gs_hint text,
    gs_container_id integer,		-- pointer to containers(id)
    gs_placed_by text,
    gs_owner_id integer			-- pointer to names(id)
);
create index waypoint_idx_name on waypoints(wpt_name);
create index waypoint_idx_id on waypoints(id);

create table names (
    id integer primary key,
    account_id integer,			-- pointer to accounts(id)
    name text,
    code text
);
create index names_idx_id on names(id);
create index names_idx_name on names(name);

create table countries (
    id integer primary key,
    name text,
    code text
);
create index countries_idx_id on countries(id);
create index countries_idx_name on countries(name);

create table states (
    id integer primary key,
    name text,
    code text
);
create index states_idx_id on states(id);
create index states_idx_name on states(name);

create table symbols (
    id integer primary key,
    symbol text
);
create index symbols_idx_id on symbols(id);
create index symbols_idx_symbol on symbols(symbol);
insert into symbols(symbol) values("Final Location");
insert into symbols(symbol) values("Geocache Found");
insert into symbols(symbol) values("Geocache");
insert into symbols(symbol) values("Parking Area");
insert into symbols(symbol) values("Physical Stage");
insert into symbols(symbol) values("Reference Point");
insert into symbols(symbol) values("Trailhead");
insert into symbols(symbol) values("Virtual Stage");
insert into symbols(symbol) values("Waymark");
insert into symbols(symbol) values("Waymark Found");
insert into symbols(symbol) values("*");

create table pins (
    id integer primary key,
    description text,
    rgb text,
    rgb_default text
);
insert into pins(id, description, rgb, rgb_default) values(10, "Benchmark", "", "230FDC");
insert into pins(id, description, rgb, rgb_default) values(11, "Event", "", "FFD0D0");
insert into pins(id, description, rgb, rgb_default) values(12, "Earth Cache", "", "F0F0F0");
insert into pins(id, description, rgb, rgb_default) values(13, "Letterbox Cache", "", "A52A2A");
insert into pins(id, description, rgb, rgb_default) values(14, "Multi Cache", "", "F5F810");
insert into pins(id, description, rgb, rgb_default) values(15, "Mystery Cache", "", "FF00FF");
insert into pins(id, description, rgb, rgb_default) values(16, "Traditional Cache", "", "009C00");
insert into pins(id, description, rgb, rgb_default) values(17, "Virtual Cache", "", "F0F0F0");
insert into pins(id, description, rgb, rgb_default) values(18, "Webcam Cache", "", "F0F0F0");
insert into pins(id, description, rgb, rgb_default) values(19, "Wherigo Cache", "", "00FFFF");
insert into pins(id, description, rgb, rgb_default) values(20, "Locationless Cache", "", "A52A2A");
insert into pins(id, description, rgb, rgb_default) values(21, "Moveable Cache", "", "806060");
insert into pins(id, description, rgb, rgb_default) values(22, "Other Cache", "", "AAAAAA");
insert into pins(id, description, rgb, rgb_default) values(23, "Waymark Cache", "", "806060");

insert into pins(id, description, rgb, rgb_default) values(40, "Waypoint - Final Location", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(41, "Waypoint - Flag", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(42, "Waypoint - Multi Stage", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(43, "Waypoint - Parking Area", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(44, "Waypoint - Physical Stage", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(45, "Waypoint - Reference Point", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(46, "Waypoint - Trailhead", "", "000000");
insert into pins(id, description, rgb, rgb_default) values(47, "Waypoint - Virtual Stage", "", "000000");

insert into pins(id, description, rgb, rgb_default) values(99, "*", "", "A52A2A");

create table types (
    id integer primary key,
    type_major text,
    type_minor text,
    icon integer,
    pin_id integer	-- points to pins(id)
);
create index types_idx_id on types(id);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Benchmark", 100, 10);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "CITO", 101, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Cache In Trash Out Event", 101, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Earthcache", 102, 12);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Event Cache", 103, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Giga", 104, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Giga-Event Cache", 104, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "GroundspeakHQ", 105, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Groundspeak HQ", 105, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Groundspeak Block Party", 105, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Letterbox Hybrid", 106, 13);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Maze", 107, 22);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Mega", 108, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Mega-Event Cache", 108, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Multi-cache", 109, 14);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Mystery", 110, 15);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Unknown (Mystery) Cache", 110, 15);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Other", 111, 22);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Traditional Cache", 112, 16);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Traditional", 112, 16);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Unknown Cache", 113, 22);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Virtual Cache", 114, 17);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Waymark", 115, 23);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Webcam Cache", 116, 18);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Wherigo Cache", 117, 19);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Wherigo Caches", 117, 19);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Project APE Cache", 111, 22);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Locationless (Reverse) Cache", 111, 20);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "GPS Adventures Exhibit", 111, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Lost and Found Event Caches", 111, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Groundspeak Lost and Found Celebration", 111, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Moveable", 119, 21);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "TrigPoint", 118, 10);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Virtual", 114, 17);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "History", 120, 17);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Multistep Traditional cache", 112, 16);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Multistep Virtual cache", 114, 17);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Contest", 103, 11);
insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "Event", 103, 11);

insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Final Location", 200, 40);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Flag", 201, 41);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Multi Stage", 202, 42);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Parking Area", 203, 43);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Physical Stage", 204, 44);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Reference Point", 205, 45);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Trailhead", 206, 46);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "Virtual Stage", 207, 47);

insert into types(type_major, type_minor, icon, pin_id) values("Geocache", "*", 208, 99);
insert into types(type_major, type_minor, icon, pin_id) values("Waypoint", "*", 208, 99);
insert into types(type_major, type_minor, icon, pin_id) values("*", "*", 208, 99);

create table log_types (
    id integer primary key,
    logtype text,
    icon integer
);
insert into log_types(logtype, icon) values("Didn't find it", 400);
insert into log_types(logtype, icon) values("Enable Listing", 401);
insert into log_types(logtype, icon) values("Found it", 402);
insert into log_types(logtype, icon) values("Needs Archived", 403);
insert into log_types(logtype, icon) values("Needs Maintenance", 404);
insert into log_types(logtype, icon) values("Owner Maintenance", 405);
insert into log_types(logtype, icon) values("Post Reviewer Note", 406);
insert into log_types(logtype, icon) values("Publish Listing", 407);
insert into log_types(logtype, icon) values("Retract Listing", 408);
insert into log_types(logtype, icon) values("Temporarily Disable Listing", 409);
insert into log_types(logtype, icon) values("Unarchive", 410);
insert into log_types(logtype, icon) values("Update Coordinates", 411);
insert into log_types(logtype, icon) values("Webcam Photo Taken", 412);
insert into log_types(logtype, icon) values("Write note", 413);
insert into log_types(logtype, icon) values("Attended", 414);
insert into log_types(logtype, icon) values("Will Attend", 415);
insert into log_types(logtype, icon) values("Unknown", 416);
insert into log_types(logtype, icon) values("Comment", 413);
insert into log_types(logtype, icon) values("Moved", 417);
insert into log_types(logtype, icon) values("Published", 407);
insert into log_types(logtype, icon) values("Did not find it", 400);
insert into log_types(logtype, icon) values("Noted", 413);
insert into log_types(logtype, icon) values("Maintained", 405);
insert into log_types(logtype, icon) values("Needs maintenance", 404);

create table logs (
    id integer primary key,
    gc_id integer,
    waypoint_id integer,		-- points to waypoints(id)
    log_type_id integer,		-- points to log_types(id)
    datetime text,
    datetime_epoch integer,
    logger_id integer,			-- points to names(id)
    needstobelogged bool,
    log text
);
create index logs_idx_id on logs(id);
create index logs_idx_gc_id on logs(gc_id);
create index logs_idx_waypoint_id on logs(waypoint_id);

create table containers (
    id integer primary key,
    size text,
    icon integer
);
insert into containers(size, icon) values("Large", 450);
insert into containers(size, icon) values("Micro", 451);
insert into containers(size, icon) values("Not chosen", 452);
insert into containers(size, icon) values("Other", 453);
insert into containers(size, icon) values("Regular", 454);
insert into containers(size, icon) values("Small", 455);
insert into containers(size, icon) values("Virtual", 456);

create table attribute2waypoints (
    id integer primary key,
    waypoint_id integer,		-- points to waypoints(id)
    attribute_id integer,		-- points to attributes(id)
    yes bool
);
create index attribute2waypoints_idx_waypoint_id on attribute2waypoints(waypoint_id);

create table attributes (
    id integer primary key,
    label text,
    gc_id integer,			-- Not a pointer
    icon integer
);

create table image2waypoint (
    id integer primary key,
    waypoint_id integer,		-- points to waypoints(id)
    image_id integer,			-- points to images(id)
    type integer			-- 1: log image 2: cache image 3: user image
);
create index image2waypoint_idx_waypoint_id on image2waypoint(waypoint_id);
create index image2waypoint_idx_waypoint_id_type on image2waypoint(waypoint_id, type);

create table images (
    id integer primary key,
    url text,
    filename text,
    datetime integer,
    datafile text
);
create index images_idx_url on images(url);

create table travelbugs (
    id integer primary key,
    gc_id integer,			-- Not a pointer
    ref text,
    name text
);
create index travelbugs_idx_gc_id on travelbugs(gc_id);
create index travelbugs_idx_id on travelbugs(id);

create table bookmarks (
    id integer primary key,
    url text,
    name text
);
create index bookmarks_idx_id on bookmarks(id);
insert into bookmarks(name, url) values("Localhost:8000", "http://127.0.0.1:8000/");
insert into bookmarks(name, url) values("MavvieMac:8000", "http://mavviemac:8000/");
insert into bookmarks(name, url) values("Geocaching.com - Pocket Queries", "https://www.geocaching.com/pocket/");
insert into bookmarks(name, url) values("Geocaching Australia - Queries", "http://www.geocaching.com.au/my/query/");

create table travelbug2waypoint (
    id integer primary key,
    travelbug_id integer,		-- points to travelbugs(id)
    waypoint_id integer			-- points to waypoints(id)
);
create index travelbug2waypoint_idx_travelbug_id on travelbug2waypoint(travelbug_id);
create index travelbug2waypoint_idx_cache_id on travelbug2waypoint(waypoint_id);

create table accounts (
    id integer primary key,
    geocube_id integer,
    revision integer,
    enabled bool,

    site text,
    url_site text,
    url_queries text,
    accountname text,
    name_id integer,			-- points to names(id)
    protocol integer,	-- 0 none, 1 groundspeak, 2 okapi, 3 GCA

    gca_cookie_name text,
    gca_cookie_value text,
    gca_authenticate_url text,
    gca_callback_url text,

    oauth_consumer_public text,
    oauth_consumer_private text,
    oauth_request_url text,
    oauth_access_url text,
    oauth_authorize_url text,
    oauth_token text,
    oauth_token_secret text
);

create table personal_notes (
    id integer primary key,
    waypoint_id integer, 	-- points to waypoints(id)
    wp_name text,		-- in case the waypoint gets removed
    note text
);
create index personal_notes_idx_wpname on personal_notes(wp_name);
create index personal_notes_idx_waypoint_id on personal_notes(waypoint_id);
create index personal_notes_idx_id on personal_notes(id);

create table notices (
    id integer primary key,
    geocube_id integer,
    note text,
    sender text,
    date text,
    seen bool
);
create index notices_idx_id on notices(id);

create table file_imports (
    id integer primary key,
    filename text,
    filesize integer,
    last_import_epoch integer
);

create table query_imports (
    id integer primary key,
    account_id integer,		-- points to accounts(id)
    name text,
    filesize integer,
    last_import_epoch integer
);

create table tracks (
    id integer primary key,
    name text,
    startedon integer,
    stoppedon integer
);
create index tracks_idx_id on tracks(id);

create table trackelements (
    id integer primary key,
    track_id integer,		-- points to tracks(id)
    lat_int integer,		-- lat times 1000 000 for now
    lon_int integer, 		-- lon times 1000 000 for now
    height integer,
    timestamp integer,
    restart bool
);
create index trackelements_idx_id on trackelements(id);
create index trackelements_idx_trackid on trackelements(track_id);

create table externalmaps (
    id integer primary key,
    geocube_id integer,
    enabled bool,
    name text
);
create table externalmap_urls (
    id integer primary key,
    externalmap_id integer,
    model text,
    type integer,
    url text
);
