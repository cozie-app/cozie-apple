# Function to check the datatype of payloads
# This function makes sure that the payloads have always the same datatypes. 
# This check is necessary because influx only accepts values of the same datatype for a field (column), as the previous values in this field (column)
# Ideally, datatype consistency is ensured in the app instead of here.
# Project: Cozie
# Experiment: Osk, Orenth
# Author: Mario Frei, 2022

# question: data type of sound_pressure, ts_restingHeartRate # XXX

def check_type(key, value):
    # Fields with integer values
    int_fields = ['body_mass',
                  'heart_rate',
                  'ts_heartRate',
                  'ts_oxygenSaturation',
                  'ts_restingHeartRate',
                  'sound_pressure',
                  'ts_standTime',
                  'ts_stepCount',
                  'vote_count']
                  
    # Fields with float values
    float_fields = ['latitude',
                    'longitude',
                    'ts_hearingEnvironmentalExposure',
                    'ts_walkingDistance',
                    'ts_bodyMass']
                      
    if key in int_fields:
        return int(value)
        
    elif key in float_fields:
        return float(value)
        
    else:
        return value # by default no changes are made to 'value'