import { LightningElement, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';

import getEmployees from '@salesforce/apex/EmployeeController.getEmployees';
import createEmployee from '@salesforce/apex/EmployeeController.createEmployee';
import updateEmployee from '@salesforce/apex/EmployeeController.updateEmployee';
import deleteEmployee from '@salesforce/apex/EmployeeController.deleteEmployee';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const ACTIONS = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

const COLUMNS = [
    { label: 'Name', fieldName: 'Name' },
    { label: 'Email', fieldName: 'Email__c' },
    { label: 'Department', fieldName: 'Department__c' },
    { label: 'Salary', fieldName: 'Salary__c', type: 'currency' },
    { label: 'Status', fieldName: 'Status__c' },
    {
        type: 'action',
        typeAttributes: { rowActions: ACTIONS }
    }
];

export default class EmployeeList extends LightningElement {

    employees = [];
    allEmployees = [];
    columns = COLUMNS;
    wiredEmployeesResult;

    employee = {};
    isEditMode = false;
    saveLabel = 'Add New Employee';

    departmentOptions = [
        { label: 'IT', value: 'IT' },
        { label: 'HR', value: 'HR' },
        { label: 'Finance', value: 'Finance' },
        { label: 'Sales', value: 'Sales' }
    ];

    statusOptions = [
        { label: 'Active', value: 'Active' },
        { label: 'Inactive', value: 'Inactive' }
    ];

    @wire(getEmployees)
    wiredEmployees(result) {
        this.wiredEmployeesResult = result;
        if (result.data) {
            this.employees = result.data;
            this.allEmployees = result.data;
        } else if (result.error) {
            console.error(result.error);
        }
    }

    handleSearch(event) {
        const key = event.target.value.toLowerCase();
        this.employees = this.allEmployees.filter(emp =>
            emp.Name.toLowerCase().includes(key)
        );
    }

    handleChange(event) {
        const field = event.target.dataset.field;
        this.employee = { ...this.employee, [field]: event.target.value };
    }

    handleSave() {
        if (this.isEditMode) {
            updateEmployee({ emp: this.employee })
                .then(() => this.refresh())
                .then(() => this.toast('Success', 'Employee Updated'))
                .then(() => this.resetForm())
                .catch(error => this.toast('Error', error.body.message, 'error'));
        } else {
            createEmployee({ emp: this.employee })
                .then(() => this.refresh())
                .then(() => this.toast('Success', 'Employee Created'))
                .then(() => this.resetForm())
                .catch(error => this.toast('Error', error.body.message, 'error'));
        }
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'edit') {
            this.employee = { ...row };
            this.isEditMode = true;
            this.saveLabel = 'Update Employee';
        }

        if (action === 'delete') {
            deleteEmployee({ empId: row.Id })
                .then(() => this.refresh())
                .then(() => this.toast('Success', 'Employee Deleted'))
                .catch(error => this.toast('Error', error.body.message, 'error'));
        }
    }

    handleCancel() {
        this.resetForm();
    }

    refresh() {
        return refreshApex(this.wiredEmployeesResult);
    }

    resetForm() {
        this.employee = {};
        this.isEditMode = false;
        this.saveLabel = 'Add New Employee';
    }

    toast(title, message, variant = 'success') {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}