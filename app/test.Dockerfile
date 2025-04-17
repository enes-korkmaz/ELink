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

FROM ghcr.io/tsukinoko-kun/rails-chrome-webdriver:114
WORKDIR /app
COPY . /app
RUN gem update --system && \
  bundle install && \
  bundle exec rake db:create db:schema:load db:migrate db:fixtures:load && \
  bundle exec rails assets:precompile && \
  echo "#!/bin/sh" > /app/entrypoint.sh && \
  echo "set -e" >> /app/entrypoint.sh && \
  echo "bundle exec rake test:system" >> /app/entrypoint.sh && \
  echo "bundle exec rake test" >> /app/entrypoint.sh && \
  chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
