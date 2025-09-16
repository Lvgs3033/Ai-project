% Expert Medical Diagnosis System in Prolog
% This system diagnoses diseases based on symptoms provided by the user.
% It now uses a strict logic, requiring all symptoms of a disease to be present
% for a diagnosis. If no perfect match is found, it advises seeking medical advice.
% The system has been updated to also provide recovery tips and home remedies for
% specific diseases.

% --- Knowledge Base: Diseases and their associated symptoms ---

% Define diseases and their symptoms using a 'symptom_of' predicate.
% Format: symptom_of(Disease, Symptom).

% Disease 1: Common Cold
symptom_of(common_cold, sneezing).
symptom_of(common_cold, runny_nose).
symptom_of(common_cold, sore_throat).
symptom_of(common_cold, cough).
symptom_of(common_cold, headache).
symptom_of(common_cold, low_grade_fever).
symptom_of(common_cold, fatigue).

% Disease 2: Influenza (Flu)
symptom_of(influenza, high_fever).
symptom_of(influenza, body_aches).
symptom_of(influenza, headache).
symptom_of(influenza, severe_fatigue).
symptom_of(influenza, dry_cough).
symptom_of(influenza, sore_throat).
symptom_of(influenza, chills).
symptom_of(influenza, runny_nose).

% Disease 3: Strep Throat
symptom_of(strep_throat, severe_sore_throat).
symptom_of(strep_throat, fever).
symptom_of(strep_throat, swollen_tonsils).
symptom_of(strep_throat, white_patches_on_throat).
symptom_of(strep_throat, difficulty_swallowing).
symptom_of(strep_throat, red_spots_on_roof_of_mouth).

% Disease 4: Mononucleosis (Mono)
symptom_of(mononucleosis, severe_fatigue).
symptom_of(mononucleosis, high_fever).
symptom_of(mononucleosis, swollen_lymph_nodes).
symptom_of(mononucleosis, sore_throat).
symptom_of(mononucleosis, rash).
symptom_of(mononucleosis, swollen_spleen).

% Disease 5: Pneumonia
symptom_of(pneumonia, chest_pain).
symptom_of(pneumonia, productive_cough).
symptom_of(pneumonia, shortness_of_breath).
symptom_of(pneumonia, fever).
symptom_of(pneumonia, chills).
symptom_of(pneumonia, severe_fatigue).
symptom_of(pneumonia, fast_breathing).

% Disease 6: Measles
symptom_of(measles, fever).
symptom_of(measles, cough).
symptom_of(measles, runny_nose).
symptom_of(measles, red_watery_eyes).
symptom_of(measles, koplik_spots).
symptom_of(measles, full_body_rash).

% Disease 7: Dengue Fever
symptom_of(dengue_fever, high_fever).
symptom_of(dengue_fever, severe_headache).
symptom_of(dengue_fever, joint_and_muscle_pain).
symptom_of(dengue_fever, rash).
symptom_of(dengue_fever, pain_behind_eyes).
symptom_of(dengue_fever, bleeding_gums).

% Disease 8: Allergies
symptom_of(allergies, sneezing).
symptom_of(allergies, runny_nose).
symptom_of(allergies, itchy_eyes).
symptom_of(allergies, watery_eyes).
symptom_of(allergies, cough).
symptom_of(allergies, wheezing).

% Disease 9: Urinary Tract Infection (UTI)
symptom_of(uti, painful_urination).
symptom_of(uti, frequent_urination).
symptom_of(uti, cloudy_or_dark_urine).
symptom_of(uti, pelvic_pain).
symptom_of(uti, strong_smelling_urine).
symptom_of(uti, fever).

% Disease 10: Tuberculosis (TB)
symptom_of(tuberculosis, persistent_cough).
symptom_of(tuberculosis, chest_pain).
symptom_of(tuberculosis, night_sweats).
symptom_of(tuberculosis, weight_loss).
symptom_of(tuberculosis, fatigue).
symptom_of(tuberculosis, fever).
symptom_of(tuberculosis, coughing_up_blood).

% --- Inference Engine and User Interface Logic ---

% Dynamic predicate to store user's known symptoms.
% This is used to avoid asking the same question multiple times.
:- dynamic(yes_symptom/1).
:- dynamic(no_symptom/1).

% Main diagnosis predicate
diagnose :-
    write('Welcome to the Medical Diagnosis Expert System.'), nl,
    write('Please answer "yes." or "no." to the following questions.'), nl,
    % First, try to find a perfect match.
    (
        find_perfect_match(PerfectDisease) ->
        write('Based on your symptoms, the diagnosis is: '), write(PerfectDisease), nl,
        provide_information(PerfectDisease)
    ;
        % If no perfect match, find the best partial match.
        find_best_partial_match(BestDisease, BestMatchCount),
        % Check if the best match has between 1 and 5 symptoms.
        (
            BestMatchCount > 0, BestMatchCount =< 5 ->
            write('Based on your symptoms, you may have: '), write(BestDisease), nl,
            provide_information(BestDisease)
        ;
            % If no perfect match and not a partial match of 1-5 symptoms, give up.
            write('Based on your symptoms, a specific disease could not be determined.'), nl,
            write('Please consult a medical professional for a proper diagnosis.'), nl
        )
    ).

% Predicate to find a disease where all symptoms match the user's input.
find_perfect_match(Disease) :-
    disease(Disease),
    \+ (symptom_of(Disease, Symptom), \+ has_symptom(Symptom)).

% Predicate to find the best partial match by counting symptoms.
find_best_partial_match(BestDisease, BestMatchCount) :-
    findall(Count-Disease, count_matching_symptoms(Disease, Count), Matches),
    sort(0, @>=, Matches, [BestMatchCount-BestDisease|_]).

% Predicate to count how many symptoms a user has for a given disease.
count_matching_symptoms(Disease, Count) :-
    disease(Disease),
    findall(Symptom, (symptom_of(Disease, Symptom), has_symptom(Symptom)), MatchedSymptoms),
    length(MatchedSymptoms, Count).

% Predicate to ask the user if they have a symptom.
% It first checks if the answer is already known.
has_symptom(Symptom) :-
    yes_symptom(Symptom),
    !.
has_symptom(Symptom) :-
    no_symptom(Symptom),
    !,
    fail.
has_symptom(Symptom) :-
    \+ yes_symptom(Symptom),
    \+ no_symptom(Symptom),
    ask_question(Symptom).

% Predicate to ask the question and assert the answer.
ask_question(Symptom) :-
    nl,
    write('Do you have the symptom: '), write(Symptom), write('? (yes/no)'), nl,
    read(Answer),
    (
        Answer = yes ->
        assertz(yes_symptom(Symptom))
    ;
        Answer = no ->
        assertz(no_symptom(Symptom)),
        fail
    ;
        write('Invalid input. Please answer with yes. or no.'),
        ask_question(Symptom)
    ).

% Predicate to provide recovery tips and cures based on the diagnosed disease.
provide_information(common_cold) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('Tips for recovery:'), nl,
    write('* Get plenty of rest to allow your body to heal.'), nl,
    write('* Stay hydrated by drinking water and warm liquids like herbal tea.'), nl,
    write('* Use a saline nasal spray to help relieve congestion.'), nl,
    write(' '), nl,
    write('Home remedies:'), nl,
    write('* A warm honey-lemon drink can soothe a sore throat.'), nl,
    write('* Gargle with warm salt water to reduce throat pain.'), nl,
    write('* Inhale steam from a bowl of hot water to clear your sinuses.'), nl,
    nl.
provide_information(influenza) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('Tips for recovery:'), nl,
    write('* Rest is crucial. Your body needs energy to fight the virus.'), nl,
    write('* Drink lots of fluids like water, broth, and sports drinks to prevent dehydration.'), nl,
    write('* Use over-the-counter pain relievers to manage fever and body aches.'), nl,
    write(' '), nl,
    write('Home remedies:'), nl,
    write('* Drink ginger or peppermint tea to help with nausea.'), nl,
    write('* A warm compress can relieve muscle aches.'), nl,
    write('* Chicken soup can help reduce inflammation and provide hydration.'), nl,
    nl.
provide_information(strep_throat) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('Tips for recovery:'), nl,
    write('* Complete the full course of any prescribed antibiotics.'), nl,
    write('* Use a humidifier to moisten the air and soothe your throat.'), nl,
    write('* Avoid acidic or spicy foods that might irritate your throat.'), nl,
    write(' '), nl,
    write('Home remedies:'), nl,
    write('* Gargle with warm salt water several times a day.'), nl,
    write('* Drink warm liquids like herbal tea with honey.'), nl,
    write('* Eat soft foods and use throat lozenges to ease pain.'), nl,
    nl.
provide_information(_) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('No specific home remedies are available for this condition.'), nl,
    write('Please consult a medical professional.'), nl.

% Note regarding the use of home remedies.
provide_information(_) :-
    nl,
    write('**Note: Please use these remedies only if you do not have an allergy to the suggested products.**'), nl,
    nl.

% Predicate to list all diseases (for findall to work)
disease(common_cold).
disease(influenza).
disease(strep_throat).
disease(mononucleosis).
disease(pneumonia).
disease(measles).
disease(dengue_fever).
disease(allergies).
disease(uti).
disease(tuberculosis).

% To run the system, simply type 'diagnose.' in the Prolog interpreter.
% The 'clear_facts.' predicate can be used to reset the system for a new user.
clear_facts :-
    retractall(yes_symptom(_)),
    retractall(no_symptom(_)).

% Helper predicate to start a new session.
start :-
    clear_facts,
    diagnose.

%press diagnosis for direct run

% diagnose.