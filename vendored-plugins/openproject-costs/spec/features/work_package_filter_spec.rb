#-- copyright
# OpenProject Costs Plugin
#
# Copyright (C) 2009 - 2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#++

require 'spec_helper'

describe 'Filter by budget', js: true do
  let(:user) { FactoryGirl.create :admin }
  let(:project) { FactoryGirl.create :project }

  let(:wp_table) { ::Pages::WorkPackagesTable.new(project) }
  let(:filters) { ::Components::WorkPackages::Filters.new }

  let(:member) do
    FactoryGirl.create(:member,
                       user: user,
                       project: project,
                       roles: [FactoryGirl.create(:role)])
  end
  let(:status) do
    FactoryGirl.create(:status)
  end

  let(:budget) do
    FactoryGirl.create(:cost_object, project: project)
  end

  let(:work_package_with_budget) do
    FactoryGirl.create(:work_package,
                       project: project,
                       cost_object: budget)
  end

  let(:work_package_without_budget) do
    FactoryGirl.create(:work_package,
                       project: project)
  end

  before do
    login_as(user)
    member
    budget
    work_package_with_budget
    work_package_without_budget

    wp_table.visit!
  end

  it 'allows filtering for budgets' do
    filters.open

    filters.add_filter_by('Budget', 'is', budget.name, 'costObject')

    expect(wp_table).to have_work_packages_listed [work_package_with_budget]
    expect(wp_table).not_to have_work_packages_listed [work_package_without_budget]

    wp_table.save_as('Some query name')

    filters.remove_filter 'costObject'

    expect(wp_table).to have_work_packages_listed [work_package_with_budget, work_package_without_budget]

    last_query = Query.last

    wp_table.visit_query(last_query)

    expect(wp_table).to have_work_packages_listed [work_package_with_budget]
    expect(wp_table).not_to have_work_packages_listed [work_package_without_budget]

    filters.open

    filters.expect_filter_by('Budget', 'is', budget.name, 'costObject')
  end
end
