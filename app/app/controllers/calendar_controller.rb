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

class CalendarController < ApplicationController
  add_breadcrumb I18n.t("nav_bar.calendar")

  def month
    @date = Date.parse(params.fetch(:date, Date.today.to_s))
    # Adjust the events loading to filter by the date range for the current month
    @events = fetch_project_deadlines(@date).reject { |d| d[:date].nil? }.group_by { |d| d[:date] }

    Project.all.each do |project|
      start_date = project.project_date_from
      end_date = project.project_date_to

      formatted_start_date = start_date.strftime("%d.%m") if start_date.present?
      formatted_end_date = end_date.strftime("%d.%m.%y") if end_date.present?

      next if start_date.nil? || end_date.nil?

      [ start_date, end_date ].each do |date|
        @events[date] ||= []

        unless @events[date].any? { |event| event[:project] == project }
          @events[date] << {
            date: date,
            name: "#{project.project_name}",
            detail: "#{t("date.span")}: #{formatted_start_date} - #{formatted_end_date}",
            tab: nil,
            project: project
          }
        end
      end
    end
  end

  def fetch_project_deadlines(date)
    start_of_month = date.beginning_of_month
    end_of_month = date.end_of_month

    deadlines = []
    # tracks if a specific date-data combination has already been saved
    seen = Set.new

    Project.includes(:partners, :caterings, :accommodations, :transports).each do |project|
      project.partners.each do |partner|
        if partner.deadline.present? && partner.deadline.to_date.between?(start_of_month, end_of_month)
          event_key = "#{partner.deadline.to_date}-#{partner.id}-partners"
          unless seen.include?(event_key)
            deadlines << {
              date: partner.deadline.to_date,
              name: "#{t("activerecord.attributes.partner.deadline")}: #{partner.location_name}",
              detail: partner.notes,
              tab: "partners",
              project: project
            }
            seen.add(event_key)
          end
        end
      end

      project.caterings.each do |catering|
        unless catering.status =="gebucht"
          if catering.booking_deadline.present? && catering.booking_deadline.to_date.between?(start_of_month, end_of_month)
            event_key = "#{catering.booking_deadline.to_date}-#{catering.id}-caterings"
            unless seen.include?(event_key)
              deadlines << {
                date: catering.booking_deadline.to_date,
                name: "#{t("activerecord.attributes.catering.booking_deadline")}: #{t("activerecord.attributes.project.catering")}",
                detail: catering.notes,
                tab: "catering",
                project: project
              }
              seen.add(event_key)
            end
          end
        end
      end

      project.accommodations.each do |accommodation|
        unless accommodation.status =="gebucht"
          if accommodation.booking_deadline.present? && accommodation.booking_deadline.to_date.between?(start_of_month, end_of_month)
            event_key = "#{accommodation.booking_deadline.to_date}-#{accommodation.id}-accommodations"
            unless seen.include?(event_key)
              deadlines << {
                date: accommodation.booking_deadline.to_date,
                name: "#{t("activerecord.attributes.accommodation.booking_deadline")}: #{t("activerecord.attributes.project.accommodations")}",
                detail: accommodation.notes,
                tab: "accommodations",
                project: project
              }
              seen.add(event_key)
            end
          end
        end
      end

      project.transports.each do |transport|
        unless transport.status =="gebucht"
          if transport.booking_deadline.present? && transport.booking_deadline.to_date.between?(start_of_month, end_of_month)
            event_key = "#{transport.booking_deadline.to_date}-#{transport.id}-transports"
            unless seen.include?(event_key)
              deadlines << {
                date: transport.booking_deadline.to_date,
                name: "#{t("activerecord.attributes.transport.booking_deadline")}: #{t("activerecord.attributes.project.transport")}",
                detail: transport.notes,
                tab: "transport",
                project: project
              }
              seen.add(event_key)
            end
          end
        end
      end
    end
    deadlines
  end
end
