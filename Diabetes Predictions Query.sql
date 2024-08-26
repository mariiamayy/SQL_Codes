/*
Practice Project 

Answering questions and analyzing Diabetes Prediction dataset using basic to advanced SQL queries
*/


-- 1. Retrieve the Patient_id and ages of all patients.
SELECT patient_id, d_o_b,
DATEDIFF(YEAR, d_o_b, GETDATE()) - 
CASE 
WHEN DATEADD(YEAR, DATEDIFF(YEAR, d_o_b , GETDATE()),  d_o_b) > GETDATE() 
THEN 1 
ELSE 0 
END AS Age
FROM Diabetes_predictions

-- 2. Select all female patients who are olderthan 30.
SELECT *,
DATEDIFF(YEAR, d_o_b, GETDATE()) - 
CASE 
WHEN DATEADD(YEAR, DATEDIFF(YEAR, d_o_b , GETDATE()),  d_o_b) > GETDATE() 
THEN 1 
ELSE 0 
END AS Age
FROM Diabetes_predictions
where DATEDIFF(YEAR, d_o_b, GETDATE()) - 
CASE 
WHEN DATEADD(YEAR, DATEDIFF(YEAR, d_o_b , GETDATE()),  d_o_b) > GETDATE() 
THEN 1 
ELSE 0 
END >30
And gender = 'Female'

-- 3. Calculate the average BMI of patients.
select AVG(bmi) as average_bmi from Diabetes_predictions 

-- 4. List patients in descending order of blood glucose levels.
select * from Diabetes_predictions
order by blood_glucose_level desc 

-- 5. Find patients who have hypertension and diabetes.
select * from Diabetes_predictionswhere hypertension = 1 and diabetes = 1 -- 6. Determine the number of patients with heart disease.
select count(patient_id) as patients_with_heart_disease from Diabetes_predictions
where heart_disease = 1

-- 7. Group patients by smoking history and count how many smokers and nonsmokers there are.
select smoking_history, count(patient_id) as number_of_patients from Diabetes_predictions
group by smoking_history

-- 8. Retrieve the Patient_id of patients who have a BMI greater than the average BMI.
select patient_id, bmi from Diabetes_predictions
where bmi > ( select AVG(bmi) from  Diabetes_predictions )

-- 9. Find the patient with the highest HbA1c level and the patient with the lowest HbA1clevel.
select max(HbA1c_level)as highest, min(HbA1c_level) as lowest from Diabetes_predictions

select * from Diabetes_predictions
where hba1c_level = (select max(HbA1c_level) from Diabetes_predictions) 
or hba1c_level = (select min(HbA1c_level) from Diabetes_predictions) 


-- 10. Calculate the age of patients in years (assuming the current date as of now).
SELECT patient_id, d_o_b,
DATEDIFF(YEAR, d_o_b, GETDATE()) - 
CASE 
WHEN DATEADD(YEAR, DATEDIFF(YEAR, d_o_b , GETDATE()),  d_o_b) > GETDATE() 
THEN 1 
ELSE 0 
END AS Age
FROM Diabetes_predictions

-- 11. Rank patients by blood glucose level within each gender group.
SELECT patient_id,gender,blood_glucose_level,
RANK() OVER (PARTITION BY gender ORDER BY blood_glucose_level DESC) AS rank
FROM Diabetes_predictions

-- 12. Update the smoking history of patients who are olderthan 40 to "Ex-smoker."
update Diabetes_predictions
set smoking_history = 'Ex_smoker' 
where DATEDIFF(YEAR, d_o_b, GETDATE()) - 
CASE 
WHEN DATEADD(YEAR, DATEDIFF(YEAR, d_o_b , GETDATE()),  d_o_b) > GETDATE() 
THEN 1 
ELSE 0 
END >40

-- 13. Insert a new patient into the database with sample data.
insert into Diabetes_predictions values ('Aaron Cramer', 'PT100101','Female','1995-06-28', 0, 0, 'current', 23.26,6,150,0)

-- 14. Delete all patients with heart disease from the database.
delete from Diabetes_predictions
where heart_disease = 1

-- 15. Find patients who have hypertension but not diabetes using the EXCEPT operator.select * from Diabetes_predictionswhere hypertension = 1except select * from Diabetes_predictions where diabetes = 1-- 16. Define a unique constraint on the "patient_id" column to ensure its values are unique.
Alter table diabetes_predictions
add constraint unique_id unique (patient_id)

SELECT *
FROM sys.indexes
WHERE is_unique = 1 AND object_id = OBJECT_ID('diabetes_predictions')

-- 17. Create a view that displays the Patient_ids, ages, and BMI of patients.
Create view Patients_Summary as
select patient_id, d_o_b,
DATEDIFF(YEAR, d_o_b, GETDATE()) - 
CASE 
WHEN DATEADD(YEAR, DATEDIFF(YEAR, d_o_b , GETDATE()),  d_o_b) > GETDATE() 
THEN 1 
ELSE 0 
END AS Age, bmi from Diabetes_predictions

select * from Patients_Summary

-- 18. Suggest improvements in the database schema to reduce data redundancy and improve data integrity.
/* 
- Table design: To create a separete tables for employees, patients and medical condition while choosing the appropriate unique
keys and relationships between tables
- Ensuring appropriate data types 
- Applying data constraints: Primary keys, unique constraints, not null
*/

-- 19. Explain how you can optimize the performance of SQL queries on this dataset.
/* 
- Avoiding the use of unnecessary columns and complex operations 
- Using the most appropriate data types for each column
- Using indexing for primary keys or columning indexing for columns most retrieved or used in filtering
*/


