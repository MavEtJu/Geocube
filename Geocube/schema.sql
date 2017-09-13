-- Scheme for Geocube

create table config (
    id integer primary key,
    key text,
    value text
);
create index config_idx_key on config(key);
insert into config(key, value) values("url_sites", "https://geocube.mavetju.org/geocube_sites.5.geocube");
insert into config(key, value) values("url_notices", "https://geocube.mavetju.org/geocube_notices.5.geocube");
insert into config(key, value) values("url_externalmaps", "https://geocube.mavetju.org/geocube_externalmaps.5.geocube");
insert into config(key, value) values("url_countries", "https://geocube.mavetju.org/geocube_countries.5.geocube");
insert into config(key, value) values("url_states", "https://geocube.mavetju.org/geocube_states.5.geocube");
insert into config(key, value) values("url_attributes", "https://geocube.mavetju.org/geocube_attributes.5.geocube");
insert into config(key, value) values("url_types", "https://geocube.mavetju.org/geocube_types.5.geocube");
insert into config(key, value) values("url_pins", "https://geocube.mavetju.org/geocube_pins.5.geocube");
insert into config(key, value) values("url_bookmarks", "https://geocube.mavetju.org/geocube_bookmarks.5.geocube");
insert into config(key, value) values("url_containers", "https://geocube.mavetju.org/geocube_containers.5.geocube");
insert into config(key, value) values("url_logstrings", "https://geocube.mavetju.org/geocube_logstrings.5.geocube");
insert into config(key, value) values("url_versions", "https://geocube.mavetju.org/geocube_versions.geocube");
insert into config(key, value) values("version", "60");

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
insert into groups(name, usergroup, deletable) values("All Waypoints - Not Found", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Manually entered", 0, 0);
insert into groups(name, usergroup, deletable) values("All Waypoints - Ignored", 0, 0);
insert into groups(name, usergroup, deletable) values("Last Import", 0, 0);
insert into groups(name, usergroup, deletable) values("Last Import - New", 0, 0);
insert into groups(name, usergroup, deletable) values("Live Import", 1, 0);
insert into groups(name, usergroup, deletable) values("Manual waypoints", 1, 0);
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

    wpt_lat float,
    wpt_lon float,
    wpt_name text,
    wpt_description text,
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
    planned bool,
    date_lastlog_epoch integer,
    date_lastimport_epoch integer,

    gs_enabled bool,
    gs_archived bool,
    gs_available bool,
    gs_country_id integer,		-- pointer to countries(id)
    gca_locale_id integer,		-- pointer to locales(id)
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

create table locales (
    id integer primary key,
    name text
);
create index locales_idx_id on locales(id);
create index locales_idx_name on locales(name);

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

create table types (
    id integer primary key,
    type_major text,
    type_minor text,
    icon integer,
    pin_id integer,	-- points to pins(id)
    has_boundary bool
);
create index types_idx_id on types(id);

create table logs (
    id integer primary key,
    gc_id integer,
    waypoint_id integer,		-- points to waypoints(id)
    log_string_id integer,		-- points to log_strings(id)
    datetime_epoch integer,
    logger_id integer,			-- points to names(id)
    needstobelogged bool,
    locallog bool,
    log text,
    lat float,
    lon float
);
create index logs_idx_id on logs(id);
create index logs_idx_gc_id on logs(gc_id);
create index logs_idx_waypoint_id on logs(waypoint_id);

create table containers (
    id integer primary key,
    size text,
    icon integer,
    gc_id integer
);

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
    name text,
    owner_id integer,			-- points to names(id)
    carrier_id integer,			-- points to names(id)
    waypoint_name string,
    log_type integer,			-- 0 not, 1 visited
    code text
);
create index travelbugs_idx_gc_id on travelbugs(gc_id);
create index travelbugs_idx_id on travelbugs(id);

create table bookmarks (
    id integer primary key,
    import_id integer,
    url text,
    name text
);
create index bookmarks_idx_id on bookmarks(id);

create table travelbug2waypoint (
    id integer primary key,
    travelbug_id integer,		-- points to travelbugs(id)
    waypoint_id integer			-- points to waypoints(id)
);
create index travelbug2waypoint_idx_travelbug_id on travelbug2waypoint(travelbug_id);
create index travelbug2waypoint_idx_cache_id on travelbug2waypoint(waypoint_id);

create table protocols (
    id integer primary key,
    name text
);
insert into protocols(id, name) values(1, "LiveAPI");
insert into protocols(id, name) values(2, "OKAPI");
insert into protocols(id, name) values(3, "GCA");
insert into protocols(id, name) values(4, "GCA2");
insert into protocols(id, name) values(5, "GGCW");
insert into protocols(id, name) values(6, "Geocaching.su");
insert into protocols(id, name) values(7, "TrigpointingUK");
insert into protocols(id, name) values(8, "Geocube");

create table accounts (
    id integer primary key,
    geocube_id integer,
    revision integer,
    enabled bool,

    site text,
    url_site text,
    url_queries text,
    accountname_id integer,		-- points to names(id)
    protocol_id integer,		-- points to protocols(id)
    distance_minimum integer,

    authentication_name text,
    authentication_password text,

    gca_cookie_name text,
    gca_cookie_value text,
    gca_authenticate_url text,
    gca_callback_url text,

    oauth_consumer_public text,
    oauth_consumer_public_sharedsecret text,
    oauth_consumer_private text,
    oauth_consumer_private_sharedsecret text,
    oauth_request_url text,
    oauth_access_url text,
    oauth_authorize_url text,
    oauth_token text,
    oauth_token_secret text
);

create table personal_notes (
    id integer primary key,
    wp_name text,		-- in case the waypoint gets removed
    note text
);
create index personal_notes_idx_wpname on personal_notes(wp_name);
create index personal_notes_idx_id on personal_notes(id);

create table notices (
    id integer primary key,
    geocube_id integer,
    note text,
    sender text,
    date text,
    url text,
    seen bool
);
create index notices_idx_id on notices(id);

create table kml_files (
    id integer primary key,
    filename text,
    enabled bool
);

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
    lat float,
    lon float,
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

create table log_strings (
    id integer primary key,
    display_string text,
    log_string text,
    default_note bool,
    default_found bool,
    default_visit bool,
    default_dropoff bool,
    default_pickup bool,
    default_discover bool,
    protocol_id integer,	-- points to protocols(id)
    icon integer,
    found integer
);

create table log_string_waypoints (
    id integer primary key,
    wptype integer,		-- Unknown = 0, Event, Waypoint, TrackablePerson, TrackableWaypoint, Moveable, Webcam
    log_string_id integer	-- points to log_strings(id)
);
create index log_string_waypoints_idx  on log_string_waypoints(id);

create table listdata (
    id integer primary key,
    waypoint_id integer,	-- points to waypoints(id)
    type integer,		-- 0: HIGHLIGHTED, 1: IGNORED, 2: MARKEDFOUND,
				-- 3: INPROGRESS, 4: MARKEDDNF,
    datetime integer
);
create index listdata_idx_id  on listdata(id);

create table log_templates (
    id integer primary key,
    name text,
    text text
);
create index log_templates_idx  on log_templates(id);

create table log_macros (
    id integer primary key,
    name text,
    text text
);
create index log_macros_idx  on log_macros(id);

create table languages (
    id integer primary key,
    language text,
    country text
);
create index languages_idx on languages(id);
insert into languages(language, country) values("en", "");
insert into languages(language, country) values("en", "US");
insert into languages(language, country) values("nl", "");
