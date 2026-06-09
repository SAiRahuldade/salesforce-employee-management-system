import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getAttendances from '@salesforce/apex/AttendanceController.getAttendances';
import saveAttendance from '@salesforce/apex/AttendanceController.saveAttendance';
import deleteAttendance from '@salesforce/apex/AttendanceController.deleteAttendance';

import getLeaveRequests from '@salesforce/apex/LeaveController.getLeaveRequests';
import saveLeaveRequest from '@salesforce/apex/LeaveController.saveLeaveRequest';
import deleteLeaveRequest from '@salesforce/apex/LeaveController.deleteLeaveRequest';

import getEmployees from '@salesforce/apex/EmployeeController.getEmployees';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ATTENDANCE_ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const LEAVE_ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const ATTENDANCE_COLUMNS = [
    { label: 'Employee', fieldName: 'EmployeeName' },
    { label: 'Date', fieldName: 'Date__c', type: 'date' },
    { label: 'Check In', fieldName: 'Check_In_Time__c', type: 'date',
        typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric',
                          hour: '2-digit', minute: '2-digit' }},
    { label: 'Check Out', fieldName: 'Check_Out_Time__c', type: 'date',
        typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric',
                          hour: '2-digit', minute: '2-digit' }},
    { label: 'Status', fieldName: 'Status__c' },
    { type: 'action', typeAttributes: { rowActions: ATTENDANCE_ACTIONS } }
];

const LEAVE_COLUMNS = [
    { label: 'Employee', fieldName: 'EmployeeName' },
    { label: 'Leave Type', fieldName: 'Leave_Type__c' },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
    { label: 'Status', fieldName: 'Status__c' },
    { type: 'action', typeAttributes: { rowActions: LEAVE_ACTIONS } }
];

export default class AttendanceLeave extends LightningElement {

    // ATTENDANCE STATE
    attendances = [];
    attendanceColumns = ATTENDANCE_COLUMNS;
    wiredAttendancesResult;
    attendance = {};
    isAttendanceEditMode = false;
    attendanceSaveLabel = 'Save Attendance';

    // LEAVE STATE
    leaveRequests = [];
    leaveColumns = LEAVE_COLUMNS;
    wiredLeaveResult;
    leaveRequest = {};
    isLeaveEditMode = false;
    leaveSaveLabel = 'Apply Leave';

    // DROPDOWN OPTIONS
    employeeOptions = [];

    attendanceStatusOptions = [
        { label: 'Present', value: 'Present' },
        { label: 'Absent', value: 'Absent' },
        { label: 'Half-Day', value: 'Half-Day' }
    ];

    leaveTypeOptions = [
        { label: 'Sick Leave', value: 'Sick Leave' },
        { label: 'Casual Leave', value: 'Casual Leave' },
        { label: 'Earned Leave', value: 'Earned Leave' },
        { label: 'Maternity Leave', value: 'Maternity Leave' }
    ];

    leaveStatusOptions = [
        { label: 'Pending', value: 'Pending' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Rejected', value: 'Rejected' }
    ];

    // WIRE — ATTENDANCE
    @wire(getAttendances)
    wiredAttendances(result) {
        this.wiredAttendancesResult = result;
        if (result.data) {
            this.attendances = result.data.map(a => ({
                ...a,
                EmployeeName: a.Employee__r ? a.Employee__r.Name : ''
            }));
        } else if (result.error) {
            console.error(result.error);
        }
    }

    // WIRE — LEAVE REQUESTS
    @wire(getLeaveRequests)
    wiredLeaveRequests(result) {
        this.wiredLeaveResult = result;
        if (result.data) {
            this.leaveRequests = result.data.map(l => ({
                ...l,
                EmployeeName: l.Employee__r ? l.Employee__r.Name : ''
            }));
        } else if (result.error) {
            console.error(result.error);
        }
    }

    // WIRE — EMPLOYEES for dropdown
    @wire(getEmployees)
    wiredEmployees({ data, error }) {
        if (data) {
            this.employeeOptions = data.map(e => ({
                label: e.Name,
                value: e.Id
            }));
        } else if (error) {
            console.error(error);
        }
    }

    // ATTENDANCE FORM CHANGE
    handleAttendanceChange(event) {
        const field = event.target.dataset.field;
        this.attendance = { ...this.attendance, [field]: event.target.value };
    }

    // ATTENDANCE SAVE
    handleAttendanceSave() {
        saveAttendance({ a: this.attendance })
            .then(() => refreshApex(this.wiredAttendancesResult))
            .then(() => this.toast('Success', this.isAttendanceEditMode ? 'Attendance Updated' : 'Attendance Saved'))
            .then(() => this.resetAttendanceForm())
            .catch(error => this.toast('Error', error.body.message, 'error'));
    }

    // ATTENDANCE ROW ACTION
    handleAttendanceRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'edit') {
            this.attendance = { ...row };
            this.isAttendanceEditMode = true;
            this.attendanceSaveLabel = 'Update Attendance';
        }

        if (action === 'delete') {
            deleteAttendance({ attendanceId: row.Id })
                .then(() => refreshApex(this.wiredAttendancesResult))
                .then(() => this.toast('Success', 'Attendance Deleted'))
                .catch(error => this.toast('Error', error.body.message, 'error'));
        }
    }

    handleAttendanceCancel() {
        this.resetAttendanceForm();
    }

    resetAttendanceForm() {
        this.attendance = {};
        this.isAttendanceEditMode = false;
        this.attendanceSaveLabel = 'Save Attendance';
    }

    // LEAVE FORM CHANGE
    handleLeaveChange(event) {
        const field = event.target.dataset.field;
        this.leaveRequest = { ...this.leaveRequest, [field]: event.target.value };
    }

    // LEAVE SAVE
    handleLeaveSave() {
        saveLeaveRequest({ l: this.leaveRequest })
            .then(() => refreshApex(this.wiredLeaveResult))
            .then(() => this.toast('Success', this.isLeaveEditMode ? 'Leave Updated' : 'Leave Applied'))
            .then(() => this.resetLeaveForm())
            .catch(error => this.toast('Error', error.body.message, 'error'));
    }

    // LEAVE ROW ACTION
    handleLeaveRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'edit') {
            this.leaveRequest = { ...row };
            this.isLeaveEditMode = true;
            this.leaveSaveLabel = 'Update Leave';
        }

        if (action === 'delete') {
            deleteLeaveRequest({ leaveId: row.Id })
                .then(() => refreshApex(this.wiredLeaveResult))
                .then(() => this.toast('Success', 'Leave Request Deleted'))
                .catch(error => this.toast('Error', error.body.message, 'error'));
        }
    }

    handleLeaveCancel() {
        this.resetLeaveForm();
    }

    resetLeaveForm() {
        this.leaveRequest = {};
        this.isLeaveEditMode = false;
        this.leaveSaveLabel = 'Apply Leave';
    }

    toast(title, message, variant = 'success') {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}