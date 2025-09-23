% Expert Medical Diagnosis System in Prolog

% Knowledge Base: Diseases and their associated symptoms

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

% Inference Engine
:- dynamic(yes_symptom/1).  % Stores symptoms confirmed by the user
:- dynamic(no_symptom/1).   % Stores symptoms denied by the user

% diagnose/0 – Main decision-making logic
diagnose :-
    write('Welcome to the Medical Diagnosis Expert System.'), nl,
    write('Please answer "yes." or "no." to the following questions.'), nl,
    (
        % Step 1: Check for a perfect match (all symptoms present)
        find_perfect_match(PerfectDisease) ->
            write('Based on your symptoms, the diagnosis is: '), write(PerfectDisease), nl,
            provide_information(PerfectDisease)
    ;
        % Step 2: If no perfect match, check for best partial match
        find_best_partial_match(BestDisease, BestMatchCount),
        (
            BestMatchCount > 0, BestMatchCount =< 5 ->  % Limit partial matches to 1-5 symptoms
                write('Based on your symptoms, you may have: '), write(BestDisease), nl,
                provide_information(BestDisease)
        ;
            % Step 3: No match found
                write('Based on your symptoms, a specific disease could not be determined.'), nl,
                write('Please consult a medical professional for a proper diagnosis.'), nl
        )
    ).

% find_perfect_match/1 – Logic for perfect disease match
find_perfect_match(Disease) :-
    disease(Disease),
    \+ (symptom_of(Disease, Symptom), \+ has_symptom(Symptom)).

% find_best_partial_match/2 – Logic for partial matching
find_best_partial_match(BestDisease, BestMatchCount) :-
    findall(Count-Disease, count_matching_symptoms(Disease, Count), Matches),
    sort(0, @>=, Matches, [BestMatchCount-BestDisease|_]).

% count_matching_symptoms/2 – Counts matched symptoms
count_matching_symptoms(Disease, Count) :-
    disease(Disease),
    findall(Symptom, (symptom_of(Disease, Symptom), has_symptom(Symptom)), MatchedSymptoms),
    length(MatchedSymptoms, Count).

% has_symptom/1 + ask_question/1 – Interacts with the user for symptoms
has_symptom(Symptom) :-
    yes_symptom(Symptom), !.      % Already confirmed by user
has_symptom(Symptom) :-
    no_symptom(Symptom), !, fail. % Already denied by user
has_symptom(Symptom) :-
    \+ yes_symptom(Symptom),
    \+ no_symptom(Symptom),
    ask_question(Symptom).        % Ask user interactively

ask_question(Symptom) :-
    nl,
    write('Do you have the symptom: '), write(Symptom), write('? (yes/no)'), nl,
    read(Answer),
    (   Answer = yes -> assertz(yes_symptom(Symptom))
    ;   Answer = no -> assertz(no_symptom(Symptom)), fail
    ;   write('Invalid input. Please answer with yes. or no.'), ask_question(Symptom)
    ).

% Recovery Tips
provide_information(common_cold) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('* Rest and stay hydrated.'), nl,
    write('* Use saline spray, honey-lemon drink, and steam inhalation.'), nl.

provide_information(influenza) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('* Rest, drink fluids, and manage fever.'), nl,
    write('* Try ginger tea, warm compress, and chicken soup.'), nl.

provide_information(strep_throat) :-
    nl,
    write('--- Recovery Tips & Home Remedies ---'), nl,
    write('* Complete antibiotics, use humidifier, and avoid irritants.'), nl,
    write('* Gargle salt water, drink warm tea, and eat soft foods.'), nl.

provide_information(_) :-
    nl,
    write('No specific home remedies are available for this condition.'), nl,
    write('Please consult a medical professional.'), nl.

% List of diseases
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

% Helper predicates
clear_facts :-
    retractall(yes_symptom(_)),
    retractall(no_symptom(_)).

start :-
    clear_facts,
    diagnose.  % Starts the diagnosis session
