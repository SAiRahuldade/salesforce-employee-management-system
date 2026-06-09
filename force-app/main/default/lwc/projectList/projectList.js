import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getProjects from '@salesforce/apex/ProjectController.getProjects';
import saveProject from '@salesforce/apex/ProjectController.saveProject';
import deleteProject from '@salesforce/apex/ProjectController.deleteProject';

import getAssignments from '@salesforce/apex/AssignmentController.getAssignments';
import saveAssignment from '@salesforce/apex/AssignmentController.saveAssignment';
import deleteAssignment from '@salesforce/apex/AssignmentController.deleteAssignment';

import getEmployees from '@salesforce/apex/EmployeeController.getEmployees';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const PROJECT_ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const ASSIGNMENT_ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const PROJECT_COLUMNS = [
    { label: 'Project Name', fieldName: 'Name' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Start Date', fieldName: 'Start_Date__c', type: 'date' },
    { label: 'End Date', fieldName: 'End_Date__c', type: 'date' },
    { type: 'action', typeAttributes: { rowActions: PROJECT_ACTIONS } }
];

// FIXED — flat field names instead of Employee__r.Name
const ASSIGNMENT_COLUMNS = [
    { label: 'Employee', fieldName: 'EmployeeName' },
    { label: 'Project', fieldName: 'ProjectName' },
    { label: 'Role', fieldName: 'Role__c' },
    { label: 'Allocation %', fieldName: 'Allocation__c', type: 'number' },
    { type: 'action', typeAttributes: { rowActions: ASSIGNMENT_ACTIONS } }
];

export default class ProjectAssignment extends LightningElement {

    // PROJECT STATE
    projects = [];
    allProjects = [];
    projectColumns = PROJECT_COLUMNS;
    wiredProjectsResult;
    project = {};
    isProjectEditMode = false;
    projectSaveLabel = 'Add Project';

    // ASSIGNMENT STATE
    assignments = [];
    assignmentColumns = ASSIGNMENT_COLUMNS;
    wiredAssignmentsResult;
    assignment = {};
    isAssignmentEditMode = false;
    assignmentSaveLabel = 'Assign Employee';

    // DROPDOWN OPTIONS
    employeeOptions = [];
    projectOptions = [];

    projectStatusOptions = [
        { label: 'Planned', value: 'Planned' },
        { label: 'Ongoing', value: 'Ongoing' },
        { label: 'Completed', value: 'Completed' }
    ];

    roleOptions = [
        { label: 'Developer', value: 'Developer' },
        { label: 'Tester', value: 'Tester' },
        { label: 'Manager', value: 'Manager' }
    ];

    // WIRE — PROJECTS
    @wire(getProjects)
    wiredProjects(result) {
        this.wiredProjectsResult = result;
        if (result.data) {
            this.projects = result.data;
            this.allProjects = result.data;
            this.projectOptions = result.data.map(p => ({
                label: p.Name,
                value: p.Id
            }));
        } else if (result.error) {
            console.error(result.error);
        }
    }

    // WIRE — ASSIGNMENTS — FIXED flatten here
    @wire(getAssignments)
    wiredAssignments(result) {
        this.wiredAssignmentsResult = result;
        if (result.data) {
            this.assignments = result.data.map(a => ({
                ...a,
                EmployeeName: a.Employee__r ? a.Employee__r.Name : '',
                ProjectName: a.Project__r ? a.Project__r.Name : ''
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

    // PROJECT SEARCH
    handleProjectSearch(event) {
        const key = event.target.value.toLowerCase();
        this.projects = this.allProjects.filter(p =>
            p.Name.toLowerCase().includes(key)
        );
    }

    // PROJECT FORM CHANGE
    handleProjectChange(event) {
        const field = event.target.dataset.field;
        this.project = { ...this.project, [field]: event.target.value };
    }

    // PROJECT SAVE
    handleProjectSave() {
        saveProject({ p: this.project })
            .then(() => refreshApex(this.wiredProjectsResult))
            .then(() => this.toast('Success', this.isProjectEditMode ? 'Project Updated' : 'Project Created'))
            .then(() => this.resetProjectForm())
            .catch(error => this.toast('Error', error.body.message, 'error'));
    }

    // PROJECT ROW ACTION
    handleProjectRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'edit') {
            this.project = { ...row };
            this.isProjectEditMode = true;
            this.projectSaveLabel = 'Update Project';
        }

        if (action === 'delete') {
            deleteProject({ projectId: row.Id })
                .then(() => refreshApex(this.wiredProjectsResult))
                .then(() => this.toast('Success', 'Project Deleted'))
                .catch(error => this.toast('Error', error.body.message, 'error'));
        }
    }

    handleProjectCancel() {
        this.resetProjectForm();
    }

    resetProjectForm() {
        this.project = {};
        this.isProjectEditMode = false;
        this.projectSaveLabel = 'Add Project';
    }

    // ASSIGNMENT FORM CHANGE
    handleAssignmentChange(event) {
        const field = event.target.dataset.field;
        this.assignment = { ...this.assignment, [field]: event.target.value };
    }

    // ASSIGNMENT SAVE
    handleAssignmentSave() {
        saveAssignment({ a: this.assignment })
            .then(() => refreshApex(this.wiredAssignmentsResult))
            .then(() => this.toast('Success', this.isAssignmentEditMode ? 'Assignment Updated' : 'Employee Assigned'))
            .then(() => this.resetAssignmentForm())
            .catch(error => this.toast('Error', error.body.message, 'error'));
    }

    // ASSIGNMENT ROW ACTION
    handleAssignmentRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'edit') {
            this.assignment = { ...row };
            this.isAssignmentEditMode = true;
            this.assignmentSaveLabel = 'Update Assignment';
        }

        if (action === 'delete') {
            deleteAssignment({ assignmentId: row.Id })
                .then(() => refreshApex(this.wiredAssignmentsResult))
                .then(() => this.toast('Success', 'Assignment Deleted'))
                .catch(error => this.toast('Error', error.body.message, 'error'));
        }
    }

    handleAssignmentCancel() {
        this.resetAssignmentForm();
    }

    resetAssignmentForm() {
        this.assignment = {};
        this.isAssignmentEditMode = false;
        this.assignmentSaveLabel = 'Assign Employee';
    }

    toast(title, message, variant = 'success') {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}