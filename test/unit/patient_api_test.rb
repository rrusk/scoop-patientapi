require File.expand_path("../../test_helper", __FILE__)

class PatientApiTest  < Test::Unit::TestCase
  def setup
    patient_api = QueryExecutor.patient_api_javascript.to_s
    fixture_json = File.read('test/fixtures/patient/barry_berry.json')
    initialize_patient = 'var patient = new hQuery.Patient(barry);'
    date = Time.new(2010,1,1)
    initialize_date = "var sampleDate = new Date(#{date.to_i*1000});"
    @context = ExecJS.compile(patient_api + "\n" + fixture_json + "\n" + initialize_patient + "\n" + initialize_date)
  end

  def test_demographics
    assert_equal 'Barry', @context.eval('patient.given()')
    assert_equal 1962, @context.eval('patient.birthtime().getFullYear()')
    assert_equal 'M', @context.eval('patient.gender()')
    assert_equal 48, @context.eval('patient.age()').to_i
    assert_equal 1, @context.eval('patient.addresses().length').to_i
    assert_equal 'MA', @context.eval('patient.addresses()[0].state()')
  end

  def test_encounters
    assert_equal 2, @context.eval('patient.encounters().length')
    assert_equal '99201', @context.eval('patient.encounters()[0].type()[0].code()')
    assert_equal 'CPT', @context.eval('patient.encounters()[0].type()[0].codeSystemName()')
    assert_equal 'OP12345', @context.eval('patient.encounters()[0].id()')
    assert_equal 'Outpatient encounter', @context.eval('patient.encounters()[0].freeTextType()')
    assert_equal 'Home', @context.eval('patient.encounters()[0].dischargeDisp()')
    assert_equal '04', @context.eval('patient.encounters()[0].admitType().code()')
    assert_equal 'General Hospital', @context.eval('patient.encounters()[0].encounterProvider().last()')
    assert_equal 2005, @context.eval('patient.encounters()[0].encounterDuration().low().getFullYear()')
    assert_equal 2011, @context.eval('patient.encounters()[0].encounterDuration().hi().getFullYear()')
    assert_equal 'PCP referred', @context.eval('patient.encounters()[0].reasonForVisit().reasonText()')
    assert_equal 'xx', @context.eval('patient.encounters()[0].reasonForVisit().reasonCode().code()')
  end

  def test_procedures
    assert_equal 1, @context.eval('patient.procedures().length')
    assert_equal '44388', @context.eval('patient.procedures()[0].type()[0].code()')
    assert_equal 'CPT', @context.eval('patient.procedures()[0].type()[0].codeSystemName()')
    assert_equal 'Colonscopy', @context.eval('patient.procedures()[0].freeTextType()')
    assert @context.eval('patient.procedures()[0].includesCodeFrom({"CPT": ["44388"]})')
    assert_equal 1, @context.eval('patient.procedures().match({"CPT": ["44388"]})')
    assert_equal 0, @context.eval('patient.procedures().match({"CPT": ["44388"]}, sampleDate)')
  end

  def test_vital_signs
    assert_equal 2, @context.eval('patient.vitalSigns().length')
    assert_equal '105539002', @context.eval('patient.vitalSigns()[0].type()[0].code()')
    assert_equal 'SNOMED-CT', @context.eval('patient.vitalSigns()[0].type()[0].codeSystemName()')
    assert_equal 'completed', @context.eval('patient.vitalSigns()[0].status()')
    assert_equal 132, @context.eval('patient.vitalSigns()[1].value()["scalar"]')
    assert_equal '46680005', @context.eval('patient.vitalSigns()[1].resultType().code()')
    assert_equal 'BP taken sitting', @context.eval('patient.vitalSigns()[1].comment()')
  end

  def test_conditions
    assert_equal 2, @context.eval('patient.conditions().length')
    assert @context.eval('patient.conditions().match({"SNOMED-CT": ["105539002"]})')
    assert @context.eval('patient.conditions().match({"SNOMED-CT": ["109838007"]})')
  end

  def test_medications
    assert_equal 1, @context.eval('patient.medications().length')
    assert_equal 24, @context.eval('patient.medications()[0].administrationTiming().period().value()')
    assert_equal 'tablet', @context.eval('patient.medications()[0].dose().unit()')
    assert_equal 'Multivitamin', @context.eval('patient.medications()[0].medicationInformation().freeTextProductName()')
    assert_equal 1, @context.eval('patient.medications().match({"RxNorm": ["89905"]})')
    assert_equal 'C38288', @context.eval('patient.medications()[0].route().code()')
    assert_equal 30, @context.eval('patient.medications()[0].fulfillmentHistory()[0].quantityDispensed().value()')
    assert_equal 'Bobby', @context.eval('patient.medications()[0].fulfillmentHistory()[0].provider().person().given()')
    assert @context.eval('patient.medications()[0].typeOfMedication().isOverTheCounter()')
    assert @context.eval('patient.medications()[0].statusOfMedication().isActive()')
    assert_equal 30, @context.eval('patient.medications()[0].orderInformation()[0].quantityOrdered().value()')
    assert_equal 20, @context.eval('patient.medications()[0].orderInformation()[0].fills()')
  end
  
  def test_immunizations
    assert_equal 2, @context.eval('patient.immunizations().length')
    assert @context.eval('patient.immunizations().match({"CVX": ["03"]})')
    assert_equal 'MMR', @context.eval('patient.immunizations()[0].medicationInformation().freeTextProductName()')
    assert_equal 2, @context.eval('patient.immunizations()[0].medicationSeriesNumber().value()')
    assert_equal 'vaccine', @context.eval('patient.immunizations()[0].comment()')
    assert @context.eval('patient.immunizations()[1].refusalReason().isImmune()')
  end
end