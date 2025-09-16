% ---------------- Expert Medical Diagnosis System ----------------
% Knowledge Base for Disease Diagnosis

% Diseases and their symptoms
disease(common_cold, [
    fever, cough, sore_throat, runny_nose, sneezing, fatigue
]).

disease(influenza, [
    fever, cough, headache, muscle_aches, chills, sweating, fatigue
]).

disease(covid_19, [
    fever, cough, shortness_of_breath, fatigue, loss_of_appetite, muscle_aches
]).

disease(strep_throat, [
    sore_throat, fever, headache, difficulty_swallowing, swollen_lymph_nodes
]).

disease(gastroenteritis, [
    nausea, vomiting, diarrhea, abdominal_pain, fever, headache
]).

disease(pneumonia, [
    cough, fever, chills, shortness_of_breath, chest_pain, fatigue
]).

disease(uti, [
    frequent_urination, painful_urination, abdominal_pain, fever
]).

disease(allergic_rhinitis, [
    sneezing, runny_nose, red_eyes, fatigue
]).

disease(migraine, [
    headache, nausea, dizziness, blurred_vision
]).

disease(hypertension, [
    headache, dizziness, palpitations, nosebleed
]).

% --- New Diseases and Symptoms ---
disease(malaria, [
    high_fever, chills, sweating, headache, nausea, muscle_pain, fatigue
]).

disease(typhoid, [
    high_fever, headache, abdominal_pain, weakness, rose_spots, diarrhea_or_constipation
]).

% Patient data structure
patient_data([
    age(35),
    gender(male),
    symptoms([fever, cough, headache])
]).

% Rules for diagnosis
diagnose(Disease, Probability) :-
    disease(Disease, DiseaseSymptoms),
    patient_data(PatientData),
    member(symptoms(PatientSymptoms), PatientData),
    member(age(Age), PatientData),
    member(gender(Gender), PatientData),
    symptom_match(PatientSymptoms, DiseaseSymptoms, MatchCount, TotalSymptoms),
    base_probability(MatchCount, TotalSymptoms, BaseProb),
    adjust_probability(Age, Gender, Disease, BaseProb, Probability).

symptom_match(PatientSymptoms, DiseaseSymptoms, MatchCount, TotalSymptoms) :-
    findall(Symptom, (member(Symptom, DiseaseSymptoms), member(Symptom, PatientSymptoms)), Matches),
    length(Matches, MatchCount),
    length(DiseaseSymptoms, TotalSymptoms).

base_probability(MatchCount, TotalSymptoms, Probability) :-
    Probability is (MatchCount / TotalSymptoms) * 100.

% Adjust probability based on age and gender factors
adjust_probability(Age, _Gender, hypertension, BaseProb, AdjustedProb) :-
    (Age > 50 -> Adjustment = 20; Adjustment = 0),
    AdjustedProb is min(95, BaseProb + Adjustment).

adjust_probability(_Age, Gender, uti, BaseProb, AdjustedProb) :-
    (Gender = female -> Adjustment = 15; Adjustment = 0),
    AdjustedProb is min(95, BaseProb + Adjustment).

adjust_probability(_Age, _Gender, _Disease, BaseProb, BaseProb).

% Find all possible diagnoses
find_diagnoses(Diagnoses) :-
    findall(Disease-Probability, diagnose(Disease, Probability), Diagnoses).

% Sort diagnoses by probability (highest first)
rank_diagnoses(RankedDiagnoses) :-
    find_diagnoses(Diagnoses),
    predsort(compare_probabilities, Diagnoses, RankedDiagnoses).

compare_probabilities(Order, _-Prob1, _-Prob2) :-
    (Prob1 > Prob2 -> Order = >; 
     Prob1 < Prob2 -> Order = <; 
     Order = =).

% Get disease details
get_disease_details(Disease, Details) :-
    disease(Disease, Symptoms),
    disease_description(Disease, Description),
    recommended_actions(Disease, Actions),
    Details = json([name=Disease, symptoms=Symptoms, description=Description, actions=Actions]).

% Disease descriptions
disease_description(common_cold, "Viral infection of the upper respiratory tract").
disease_description(influenza, "Viral infection that attacks your respiratory system").
disease_description(covid_19, "Respiratory illness caused by the SARS-CoV-2 virus").
disease_description(strep_throat, "Bacterial infection that causes inflammation and pain in the throat").
disease_description(gastroenteritis, "Inflammation of the stomach and intestines").
disease_description(pneumonia, "Infection that inflames air sacs in one or both lungs").
disease_description(uti, "Infection in any part of the urinary system").
disease_description(allergic_rhinitis, "Allergic response causing nasal congestion, runny nose, and sneezing").
disease_description(migraine, "Headache characterized by intense throbbing pain, often with nausea and sensitivity to light").
disease_description(hypertension, "High blood pressure that can lead to serious health complications").
disease_description(malaria, "A severe disease caused by a parasite, transmitted to humans through mosquito bites").
disease_description(typhoid, "An infection caused by the bacterium Salmonella Typhi, often spread through contaminated food or water").

% Recommended actions for each disease
recommended_actions(common_cold, [
    "Home Remedy: Rest, hydrate, and use a humidifier.",
    "Home Remedy: Gargle with warm salt water to soothe a sore throat.",
    "Medical Advice: Consult a general practitioner if symptoms last more than 10 days."
]).

recommended_actions(influenza, [
    "Home Remedy: Drink plenty of fluids (water, broth) and get lots of rest.",
    "Home Remedy: A warm bath can help with muscle aches.",
    "Medical Advice: Seek a general practitioner or an infectious disease specialist for antiviral medications."
]).

recommended_actions(covid_19, [
    "Home Remedy: Isolate from others and monitor your oxygen levels.",
    "Home Remedy: Drink warm liquids and use honey for a cough.",
    "Medical Advice: Contact a pulmonologist or infectious disease doctor for breathing difficulties."
]).

recommended_actions(strep_throat, [
    "Home Remedy: Gargle with warm salt water and drink warm beverages like tea with honey.",
    "Home Remedy: Eat soft, easy-to-swallow foods.",
    "Medical Advice: See a general practitioner for a definitive diagnosis and antibiotics."
]).

recommended_actions(gastroenteritis, [
    "Home Remedy: Follow a bland diet (BRAT: bananas, rice, applesauce, toast).",
    "Home Remedy: Stay hydrated with electrolyte solutions.",
    "Medical Advice: Consult a gastroenterologist if symptoms are severe or persistent."
]).

recommended_actions(pneumonia, [
    "Home Remedy: Rest completely and use a humidifier to ease breathing.",
    "Home Remedy: Drink plenty of water to help thin mucus.",
    "Medical Advice: Promptly see a pulmonologist, as this requires medical treatment."
]).

recommended_actions(uti, [
    "Home Remedy: Increase fluid intake to help flush bacteria out of your system.",
    "Home Remedy: Avoid caffeine, alcohol, and spicy foods.",
    "Medical Advice: Consult a urologist for diagnosis and prescribed antibiotics."
]).

recommended_actions(allergic_rhinitis, [
    "Home Remedy: Use a nasal rinse and avoid known allergens.",
    "Home Remedy: Take over-the-counter antihistamines.",
    "Medical Advice: See an allergist for allergy testing and a personalized treatment plan."
]).

recommended_actions(migraine, [
    "Home Remedy: Rest in a dark, quiet room.",
    "Home Remedy: Apply a cold compress to your forehead or neck.",
    "Medical Advice: Consult a neurologist for preventive medications and specialized treatment."
]).

recommended_actions(hypertension, [
    "Home Remedy: Maintain a healthy diet, reduce sodium, and exercise regularly.",
    "Home Remedy: Practice stress-reducing activities like meditation.",
    "Medical Advice: See a cardiologist or general practitioner for regular blood pressure monitoring and medication."
]).

recommended_actions(malaria, [
    "Home Remedy: Maintain fluid and electrolyte balance through oral rehydration.",
    "Home Remedy: Get plenty of rest in a cool environment.",
    "Medical Advice: **This is a medical emergency.** Seek a tropical medicine specialist or infectious disease doctor immediately."
]).

recommended_actions(typhoid, [
    "Home Remedy: Drink boiled or purified water and eat soft, easily digestible foods.",
    "Home Remedy: Practice good hand hygiene to prevent further spread.",
    "Medical Advice: **This is a serious condition.** Consult a gastroenterologist or infectious disease specialist for antibiotic therapy."
]).

% ------------------- Web server implementation -------------------
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).

:- set_setting(http:cors, [*]).

server(Port) :-
    http_server(http_dispatch, [port(Port)]).

:- http_handler('/api/diagnose', get_diagnoses, []).

get_diagnoses(Request) :-
    cors_enable(Request, [methods([get])]),
    rank_diagnoses(RankedDiagnoses),
    findall(
        json([name=Name, probability=Prob, details=Details]),
        (
            member(Name-Prob, RankedDiagnoses),
            get_disease_details(Name, Details)
        ),
        DiagnosesJSON
    ),
    reply_json(json([diagnoses=DiagnosesJSON])).

:- http_handler('/api/patient', update_patient, [method(post)]).

update_patient(Request) :-
    cors_enable(Request, [methods([post])]),
    http_read_json_dict(Request, PatientDict),
    dict_pairs(PatientList, _, PatientDict),
    retractall(patient_data(_)),
    assertz(patient_data(PatientList)),
    reply_json(json([status=success])).

start_server :-
    server(8080),
    format('Medical diagnosis server started at http://localhost:8080~n').

stop_server :-
    http_stop_server(8080, _).
