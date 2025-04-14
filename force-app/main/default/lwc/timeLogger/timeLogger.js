import { LightningElement, track, wire } from 'lwc';
import getAssignedProjects from '@salesforce/apex/TimeLoggerController.getAssignedProjects';
import createTimeLog from '@salesforce/apex/TimeLoggerController.createTimeLog';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimeLogger extends LightningElement {
    @track projectOptions = [];
    @track timeEntries = [{
        id: 1,
        projectId: '',
        startTime: '',
        endTime: '',
        comment: '',
        duration: 0
    }];
    @track totalHours = 0;

    entryCounter = 2;

    @wire(getAssignedProjects)
    wiredProjects({ error, data }) {
        if (data) {
            this.projectOptions = data.map(p => ({ label: p.Name, value: p.Id }));
        } else if (error) {
            this.showToast('Error', 'Could not load project list', 'error');
        }
    }

    addEntry() {
        this.timeEntries.push({
            id: this.entryCounter++,
            projectId: '',
            startTime: '',
            endTime: '',
            comment: '',
            duration: 0
        });
    }

    removeEntry(event) {
        const index = event.target.dataset.index;
        if (this.timeEntries.length > 1) {
            this.timeEntries.splice(index, 1);
            this.recalculateTotalHours();
        }
    }

    handleProjectChange(event) {
        const index = event.target.dataset.index;
        this.timeEntries[index].projectId = event.detail.value;
    }

    handleStartTimeChange(event) {
        const index = event.target.dataset.index;
        this.timeEntries[index].startTime = event.detail.value;
        console.log('handleStartTimeChange : ' + index);
        this.calculateRowDuration(index);
    }

    handleEndTimeChange(event) {
        const index = event.target.dataset.index;
        this.timeEntries[index].endTime = event.detail.value;
        console.log('handleEndTimeChange : ' + index);
        this.calculateRowDuration(index);
    }

    handleCommentChange(event) {
        const index = event.target.dataset.index;
        this.timeEntries[index].comment = event.detail.value;
    }

    calculateRowDuration(index) {
        try {
            const entry = this.timeEntries[index];
    
            if (entry.startTime && entry.endTime) {
                const [startHour, startMin] = entry.startTime.split(':').map(Number);
                const [endHour, endMin] = entry.endTime.split(':').map(Number);
    
                const start = new Date(1970, 0, 1, startHour, startMin);
                const end = new Date(1970, 0, 1, endHour, endMin);
    
                let hours = (end - start) / (1000 * 60 * 60);
    
                // Guard against invalid or negative time
                entry.duration = hours > 0 ? parseFloat(hours.toFixed(2)) : 0;
    
                this.recalculateTotalHours();
                console.log(`Duration for row ${index}: ${entry.duration} hours`);
            }
        } catch (error) {
            console.error(`Error in calculateRowDuration for index ${index}:`, error);
        }
    }
    

    recalculateTotalHours() {
        let sum = 0;
        this.timeEntries.forEach(row => {
            sum += row.duration || 0;
        });
        this.totalHours = parseFloat(sum.toFixed(2));
        console.log('Total Hours:', this.totalHours);
    }
    

    handleSubmit() {
        if (this.totalHours !== 8) {
            this.showToast('Error', 'Total hours must be exactly 8.', 'error');
            return;
        }

        const promises = this.timeEntries.map(row => {
            return createTimeLog({
                projectId: row.projectId,
                startTime: row.startTime,
                endTime: row.endTime,
                comment: row.comment
            });
        });

        Promise.all(promises)
            .then(() => {
                this.showToast('Success', 'All time logs submitted!', 'success');
                this.resetForm();
            })
            .catch(error => {
                console.error(error);
                this.showToast('Error', 'Failed to log time.', 'error');
            });
    }

    resetForm() {
        this.timeEntries = [{
            id: 1,
            projectId: '',
            startTime: '',
            endTime: '',
            comment: '',
            duration: 0
        }];
        this.totalHours = 0;
        this.entryCounter = 2;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}