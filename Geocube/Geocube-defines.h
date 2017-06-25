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

#ifndef Geocube_defines_h
#define Geocube_defines_h

#define ASSERT_FINISHED \
    NSAssert(finished == YES, @"Not finished");
#define ASSERT_SELF_FIELD_EXISTS(__field__) \
    NSAssert(self.__field__ != nil, @"self.__field__")
#define ASSERT_FIELD_EXISTS(__field__) \
    NSAssert(__field__ != nil, @"__field__")

#define ASSERT_IMPORT(__expression__, __message__) \
    NSAssert(__expression__, __message__)

#endif /* Geocube_defines_h */