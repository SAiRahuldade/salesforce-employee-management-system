import { LightningElement, wire } from 'lwc';
import getDashboardStats from '@salesforce/apex/DashboardController.getDashboardStats';

const DONUT_RADIUS = 54;
const DONUT_CIRCUMFERENCE = 2 * Math.PI * DONUT_RADIUS;

const COLORS = {
    active: '#2e844a',
    inactive: '#ba0517',
    planned: '#0176d3',
    ongoing: '#ff9800',
    completed: '#2e844a',
    pending: '#fe5c4c',
    approved: '#2e844a',
    it: '#0176d3',
    hr: '#2e844a',
    finance: '#9050e9',
    sales: '#ff9800'
};

function buildDonutSegments(items) {
    const total = items.reduce((sum, item) => sum + item.value, 0);
    if (total === 0) {
        return [{
            key: 'empty',
            label: 'No Data',
            value: 0,
            color: '#e5e5e5',
            dasharray: `${DONUT_CIRCUMFERENCE} ${DONUT_CIRCUMFERENCE}`,
            dashoffset: 0,
            percent: 0,
            swatchStyle: 'background-color: #e5e5e5'
        }];
    }

    let accumulated = 0;
    return items.map((item) => {
        const fraction = item.value / total;
        const dash = fraction * DONUT_CIRCUMFERENCE;
        const segment = {
            ...item,
            dasharray: `${dash} ${DONUT_CIRCUMFERENCE}`,
            dashoffset: -accumulated,
            percent: Math.round(fraction * 100),
            swatchStyle: `background-color: ${item.color}`
        };
        accumulated += dash;
        return segment;
    });
}

function buildBarItems(items, totalOverride) {
    const total = totalOverride ?? items.reduce((sum, item) => sum + item.value, 0);
    const max = Math.max(...items.map((item) => item.value), 1);
    return items.map((item) => {
        const widthPercent = Math.round((item.value / max) * 100);
        const sharePercent = total > 0 ? Math.round((item.value / total) * 100) : 0;
        return {
            ...item,
            widthPercent,
            sharePercent,
            fillStyle: `width: ${widthPercent}%; background-color: ${item.color}`,
            columnStyle: `height: ${widthPercent}%; background-color: ${item.color}`,
            dotStyle: `background-color: ${item.color}`
        };
    });
}

export default class HrDashboard extends LightningElement {
    stats;
    error;
    loading = true;

    @wire(getDashboardStats)
    wiredStats({ error, data }) {
        if (data) {
            this.stats = data;
            this.error = undefined;
            this.loading = false;
        } else if (error) {
            this.error = error;
            this.stats = undefined;
            this.loading = false;
        }
    }

    get donutRadius() {
        return DONUT_RADIUS;
    }

    get kpiCards() {
        if (!this.stats) return [];
        return [
            { key: 'employees', label: 'Total Employees', value: this.stats.totalEmployees, icon: 'standard:people', themeClass: 'kpi-theme-blue' },
            { key: 'projects', label: 'Total Projects', value: this.stats.totalProjects, icon: 'standard:opportunity', themeClass: 'kpi-theme-orange' },
            { key: 'assignments', label: 'Assignments', value: this.stats.totalAssignments, icon: 'standard:task', themeClass: 'kpi-theme-purple' },
            { key: 'attendance', label: "Today's Attendance", value: this.stats.todayAttendance, icon: 'standard:event', themeClass: 'kpi-theme-green' }
        ];
    }

    get employeeDonutSegments() {
        if (!this.stats) return [];
        return buildDonutSegments([
            { key: 'active', label: 'Active', value: this.stats.activeEmployees, color: COLORS.active },
            { key: 'inactive', label: 'Inactive', value: this.stats.inactiveEmployees, color: COLORS.inactive }
        ]);
    }

    get employeeDonutTotal() {
        return this.stats?.totalEmployees ?? 0;
    }

    get projectBars() {
        if (!this.stats) return [];
        return buildBarItems([
            { key: 'planned', label: 'Planned', value: this.stats.plannedProjects, color: COLORS.planned },
            { key: 'ongoing', label: 'Ongoing', value: this.stats.ongoingProjects, color: COLORS.ongoing },
            { key: 'completed', label: 'Completed', value: this.stats.completedProjects, color: COLORS.completed }
        ], this.stats.totalProjects);
    }

    get departmentBars() {
        if (!this.stats) return [];
        return buildBarItems([
            { key: 'it', label: 'IT', value: this.stats.deptITEmployees, color: COLORS.it },
            { key: 'hr', label: 'HR', value: this.stats.deptHREmployees, color: COLORS.hr },
            { key: 'finance', label: 'Finance', value: this.stats.deptFinanceEmployees, color: COLORS.finance },
            { key: 'sales', label: 'Sales', value: this.stats.deptSalesEmployees, color: COLORS.sales }
        ]);
    }

    get leaveBars() {
        if (!this.stats) return [];
        const total = this.stats.pendingLeaves + this.stats.approvedLeaves;
        return buildBarItems([
            { key: 'pending', label: 'Pending', value: this.stats.pendingLeaves, color: COLORS.pending },
            { key: 'approved', label: 'Approved', value: this.stats.approvedLeaves, color: COLORS.approved }
        ], total);
    }

    get leaveTotal() {
        if (!this.stats) return 0;
        return this.stats.pendingLeaves + this.stats.approvedLeaves;
    }

    get departmentTotal() {
        if (!this.stats) return 0;
        return (
            this.stats.deptITEmployees +
            this.stats.deptHREmployees +
            this.stats.deptFinanceEmployees +
            this.stats.deptSalesEmployees
        );
    }
}
