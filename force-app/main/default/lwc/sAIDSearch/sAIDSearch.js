import { LightningElement } from 'lwc';
import validateId from '@salesforce/apex/SAIDSearchController.validateId';
import submitRecord from '@salesforce/apex/SAIDSearchController.submitRecord';
import getHolidayList from '@salesforce/apex/SAIDSearchController.getHolidayList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SAIDSearch extends LightningElement {
    searchKey;
    flag = false;
    holidayList;
    birthYear;
    handelSearchKey(event){
        this.searchKey = event.target.value;
        if(this.searchKey.toString().length==13){
             this.validateId();
        }
    }
    validateId(){
        validateId({
            saIDString : this.searchKey.toString()
        })
         .then(result => {
                this.flag = result;
                if(this.flag==false){
                    console.log('inside false');
                    this.ShowToast('Error','Invalid ID', 'error', 'dismissable');    
                }
        })
        .catch( error=>{
            console.log(error);
            this.ShowToast('Error',error, 'error', 'dismissable');
        });
    }
    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    searchSAID(){
        submitRecord({
            saIDString : this.searchKey.toString()
        })
         .then(result => {
                if(result){
                    this.ShowToast('Success','Decoding Processed Successfully', 'success', 'dismissable');
                    this.birthYear = result;
                    this.fetchHolidayDetails(this.birthYear, this.searchKey.toString());
                }
                else{
                    this.ShowToast('Error','Error while decoding the information', 'error', 'dismissable');    
                }
        })
        .catch( error=>{
            console.log(error);
            this.ShowToast('Error',error, 'error', 'dismissable');
        });    
    }
    fetchHolidayDetails(year,key){
        getHolidayList({
            Year : year,
            searchKey : key
        })
        .then(result => {
            console.log('inside holiday');
                if(result){
                        this.holidayList = result; 
                        console.log('this.holidayList--'+JSON.stringify(this.holidayList)); 
                    }
                    else{
                        this.ShowToast('Error','Integration error - Unauthorized', 'error', 'dismissable');    
                    }
                    
                
                
        })
        .catch( error=>{
            console.log(error);
            this.ShowToast('Error',error, 'error', 'dismissable');
        });

    }
}