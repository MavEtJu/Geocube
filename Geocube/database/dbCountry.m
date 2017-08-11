/*
 * Geocube
 * By Edwin Groothuis <geocube@mavetju.org>
 * Copyright 2015, 2016, 2017 Edwin Groothuis
 *
 * This file is part of Geocube.
 *
 * Geocube is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Geocube is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Geocube.  If not, see <http://www.gnu.org/licenses/>.
 */

@interface dbCountry ()

@end

@implementation dbCountry

TABLENAME(@"countries")

- (NSId)dbCreate
{
    @synchronized(db) {
        DB_PREPARE(@"insert into countries(name, code) values(?, ?)");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.code);

        DB_CHECK_OKAY;
        DB_GET_LAST_ID(self._id);
        DB_FINISH;
    }

    return self._id;
}

- (void)dbUpdate
{
    @synchronized(db) {
        DB_PREPARE(@"update countries set name = ?, code = ? where id = ?");

        SET_VAR_TEXT(1, self.name);
        SET_VAR_TEXT(2, self.code);
        SET_VAR_INT (3, self._id);

        DB_CHECK_OKAY;
        DB_FINISH;
    }
}

+ (NSArray<dbCountry *> *)dbAllXXX:(NSString *)where keys:(NSString *)keys values:(NSArray<NSObject *> *)values
{
    NSMutableArray<dbCountry *> *ss = [[NSMutableArray alloc] initWithCapacity:20];

    NSMutableString *sql = [NSMutableString stringWithString:@"select id, name, code from countries "];
    if (where != nil)
        [sql appendString:where];

    @synchronized(db) {
        DB_PREPARE_KEYSVALUES(sql, keys, values);

        DB_WHILE_STEP {
            dbCountry *c = [[dbCountry alloc] init];
            INT_FETCH (0, c._id);
            TEXT_FETCH(1, c.name);
            TEXT_FETCH(2, c.code);
            [ss addObject:c];
        }
        DB_FINISH;
    }
    return ss;
}

+ (NSArray<dbCountry *> *)dbAll
{
    return [self dbAllXXX:nil keys:nil values:nil];
}

+ (dbCountry *)dbGet:(NSId)_id
{
    return [[self dbAllXXX:@"where id = ?" keys:@"i" values:@[[NSNumber numberWithInteger:_id]]] firstObject];
}

+ (dbCountry *)dbGetByCountry:(NSString *)name
{
    return [[self dbAllXXX:@"where name = ?" keys:@"s" values:@[name]] firstObject];
}

/* Other methods */

+ (void)makeNameExist:(NSString *)name
{
    if ([dbc Country_get_byNameCode:name] == nil) {
        dbCountry *c = [[dbCountry alloc] init];
        c.name = name;
        c.code = name;
        [c dbCreate];
        [dbc Country_add:c];
    }
}

@end

/*
 _(@"country-Andorra");
 _(@"country-United Arab Emirates");
 _(@"country-Afghanistan");
 _(@"country-Antigua &amp; Barbuda");
 _(@"country-Anguilla");
 _(@"country-Albania");
 _(@"country-Armenia");
 _(@"country-Angola");
 _(@"country-Antarctica");
 _(@"country-Argentina");
 _(@"country-Samoa (American)");
 _(@"country-Austria");
 _(@"country-Australia");
 _(@"country-Aruba");
 _(@"country-Aaland Islands");
 _(@"country-Azerbaijan");
 _(@"country-Bosnia &amp; Herzegovina");
 _(@"country-Barbados");
 _(@"country-Bangladesh");
 _(@"country-Belgium");
 _(@"country-Burkina Faso");
 _(@"country-Bulgaria");
 _(@"country-Bahrain");
 _(@"country-Burundi");
 _(@"country-Benin");
 _(@"country-St Barthelemy");
 _(@"country-Bermuda");
 _(@"country-Brunei");
 _(@"country-Bolivia");
 _(@"country-Caribbean Netherlands");
 _(@"country-Brazil");
 _(@"country-Bahamas");
 _(@"country-Bhutan");
 _(@"country-Bouvet Island");
 _(@"country-Botswana");
 _(@"country-Belarus");
 _(@"country-Belize");
 _(@"country-Canada");
 _(@"country-Cocos (Keeling) Islands");
 _(@"country-Congo (Dem. Rep.)");
 _(@"country-Central African Rep.");
 _(@"country-Congo (Rep.)");
 _(@"country-Switzerland");
 _(@"country-Cote d'Ivoire");
 _(@"country-Cook Islands");
 _(@"country-Chile");
 _(@"country-Cameroon");
 _(@"country-China");
 _(@"country-Colombia");
 _(@"country-Costa Rica");
 _(@"country-Cuba");
 _(@"country-Cape Verde");
 _(@"country-Curacao");
 _(@"country-Christmas Island");
 _(@"country-Cyprus");
 _(@"country-Czech Republic");
 _(@"country-Germany");
 _(@"country-Djibouti");
 _(@"country-Denmark");
 _(@"country-Dominica");
 _(@"country-Dominican Republic");
 _(@"country-Algeria");
 _(@"country-Ecuador");
 _(@"country-Estonia");
 _(@"country-Egypt");
 _(@"country-Western Sahara");
 _(@"country-Eritrea");
 _(@"country-Spain");
 _(@"country-Ethiopia");
 _(@"country-Finland");
 _(@"country-Fiji");
 _(@"country-Falkland Islands");
 _(@"country-Micronesia");
 _(@"country-Faroe Islands");
 _(@"country-France");
 _(@"country-Gabon");
 _(@"country-Great Britain (UK)");
 _(@"country-Grenada");
 _(@"country-Georgia");
 _(@"country-French Guiana");
 _(@"country-Guernsey");
 _(@"country-Ghana");
 _(@"country-Gibraltar");
 _(@"country-Greenland");
 _(@"country-Gambia");
 _(@"country-Guinea");
 _(@"country-Guadeloupe");
 _(@"country-Equatorial Guinea");
 _(@"country-Greece");
 _(@"country-South Georgia &amp; the South Sandwich Islands");
 _(@"country-Guatemala");
 _(@"country-Guam");
 _(@"country-Guinea-Bissau");
 _(@"country-Guyana");
 _(@"country-Hong Kong");
 _(@"country-Heard Island &amp; McDonald Islands");
 _(@"country-Honduras");
 _(@"country-Croatia");
 _(@"country-Haiti");
 _(@"country-Hungary");
 _(@"country-Indonesia");
 _(@"country-Ireland");
 _(@"country-Israel");
 _(@"country-Isle of Man");
 _(@"country-India");
 _(@"country-British Indian Ocean Territory");
 _(@"country-Iraq");
 _(@"country-Iran");
 _(@"country-Iceland");
 _(@"country-Italy");
 _(@"country-Jersey");
 _(@"country-Jamaica");
 _(@"country-Jordan");
 _(@"country-Japan");
 _(@"country-Kenya");
 _(@"country-Kyrgyzstan");
 _(@"country-Cambodia");
 _(@"country-Kiribati");
 _(@"country-Comoros");
 _(@"country-St Kitts &amp; Nevis");
 _(@"country-Korea (North)");
 _(@"country-Korea (South)");
 _(@"country-Kuwait");
 _(@"country-Cayman Islands");
 _(@"country-Kazakhstan");
 _(@"country-Laos");
 _(@"country-Lebanon");
 _(@"country-St Lucia");
 _(@"country-Liechtenstein");
 _(@"country-Sri Lanka");
 _(@"country-Liberia");
 _(@"country-Lesotho");
 _(@"country-Lithuania");
 _(@"country-Luxembourg");
 _(@"country-Latvia");
 _(@"country-Libya");
 _(@"country-Morocco");
 _(@"country-Monaco");
 _(@"country-Moldova");
 _(@"country-Montenegro");
 _(@"country-St Martin (French part)");
 _(@"country-Madagascar");
 _(@"country-Marshall Islands");
 _(@"country-Macedonia");
 _(@"country-Mali");
 _(@"country-Myanmar (Burma)");
 _(@"country-Mongolia");
 _(@"country-Macau");
 _(@"country-Northern Mariana Islands");
 _(@"country-Martinique");
 _(@"country-Mauritania");
 _(@"country-Montserrat");
 _(@"country-Malta");
 _(@"country-Mauritius");
 _(@"country-Maldives");
 _(@"country-Malawi");
 _(@"country-Mexico");
 _(@"country-Malaysia");
 _(@"country-Mozambique");
 _(@"country-Namibia");
 _(@"country-New Caledonia");
 _(@"country-Niger");
 _(@"country-Norfolk Island");
 _(@"country-Nigeria");
 _(@"country-Nicaragua");
 _(@"country-Netherlands");
 _(@"country-Norway");
 _(@"country-Nepal");
 _(@"country-Nauru");
 _(@"country-Niue");
 _(@"country-New Zealand");
 _(@"country-Oman");
 _(@"country-Panama");
 _(@"country-Peru");
 _(@"country-French Polynesia");
 _(@"country-Papua New Guinea");
 _(@"country-Philippines");
 _(@"country-Pakistan");
 _(@"country-Poland");
 _(@"country-St Pierre &amp; Miquelon");
 _(@"country-Pitcairn");
 _(@"country-Puerto Rico");
 _(@"country-Palestine");
 _(@"country-Portugal");
 _(@"country-Palau");
 _(@"country-Paraguay");
 _(@"country-Qatar");
 _(@"country-Reunion");
 _(@"country-Romania");
 _(@"country-Serbia");
 _(@"country-Russia");
 _(@"country-Rwanda");
 _(@"country-Saudi Arabia");
 _(@"country-Solomon Islands");
 _(@"country-Seychelles");
 _(@"country-Sudan");
 _(@"country-Sweden");
 _(@"country-Singapore");
 _(@"country-St Helena");
 _(@"country-Slovenia");
 _(@"country-Svalbard &amp; Jan Mayen");
 _(@"country-Slovakia");
 _(@"country-Sierra Leone");
 _(@"country-San Marino");
 _(@"country-Senegal");
 _(@"country-Somalia");
 _(@"country-Suriname");
 _(@"country-South Sudan");
 _(@"country-Sao Tome &amp; Principe");
 _(@"country-El Salvador");
 _(@"country-St Maarten (Dutch part)");
 _(@"country-Syria");
 _(@"country-Swaziland");
 _(@"country-Turks &amp; Caicos Is");
 _(@"country-Chad");
 _(@"country-French Southern &amp; Antarctic Lands");
 _(@"country-Togo");
 _(@"country-Thailand");
 _(@"country-Tajikistan");
 _(@"country-Tokelau");
 _(@"country-East Timor");
 _(@"country-Turkmenistan");
 _(@"country-Tunisia");
 _(@"country-Tonga");
 _(@"country-Turkey");
 _(@"country-Trinidad &amp; Tobago");
 _(@"country-Tuvalu");
 _(@"country-Taiwan");
 _(@"country-Tanzania");
 _(@"country-Ukraine");
 _(@"country-Uganda");
 _(@"country-US minor outlying islands");
 _(@"country-United States");
 _(@"country-Uruguay");
 _(@"country-Uzbekistan");
 _(@"country-Vatican City");
 _(@"country-St Vincent");
 _(@"country-Venezuela");
 _(@"country-Virgin Islands (UK)");
 _(@"country-Virgin Islands (US)");
 _(@"country-Vietnam");
 _(@"country-Vanuatu");
 _(@"country-Wallis &amp; Futuna");
 _(@"country-Samoa (western)");
 _(@"country-Yemen");
 _(@"country-Mayotte");
 _(@"country-South Africa");
 _(@"country-Zambia");
 _(@"country-Zimbabwe");
 _(@"country-Locationless");
*/
