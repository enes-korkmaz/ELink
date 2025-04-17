# Copyright (C) 2025 Frank Mayer, Enes Korkmaz, Jascha Sonntag, Andreas Rothaler, Eray Akyazililar, Jan Magister
#
# This file is part of Elink.
#
# Elink is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Elink is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Elink. If not, see <http://www.gnu.org/licenses/>.

FROM ruby:3
RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev vim
ENV EDITOR vim
RUN mkdir /app
WORKDIR /app
RUN gem update --system
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install --gemfile /app/Gemfile
CMD bash
