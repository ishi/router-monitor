require 'spec_helper'

describe StatisticValuesController do

  # This should return the minimal set of attributes required to create a valid
  # StatisticValue. As you add validations to StatisticValue, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end

  describe "GET index" do
    it "assigns all statistic_values as @statistic_values" do
      statistic_value = StatisticValue.create! valid_attributes
      get :index
      assigns(:statistic_values).should eq([statistic_value])
    end
  end

  describe "GET show" do
    it "assigns the requested statistic_value as @statistic_value" do
      statistic_value = StatisticValue.create! valid_attributes
      get :show, :id => statistic_value.id.to_s
      assigns(:statistic_value).should eq(statistic_value)
    end
  end

  describe "GET new" do
    it "assigns a new statistic_value as @statistic_value" do
      get :new
      assigns(:statistic_value).should be_a_new(StatisticValue)
    end
  end

  describe "GET edit" do
    it "assigns the requested statistic_value as @statistic_value" do
      statistic_value = StatisticValue.create! valid_attributes
      get :edit, :id => statistic_value.id.to_s
      assigns(:statistic_value).should eq(statistic_value)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new StatisticValue" do
        expect {
          post :create, :statistic_value => valid_attributes
        }.to change(StatisticValue, :count).by(1)
      end

      it "assigns a newly created statistic_value as @statistic_value" do
        post :create, :statistic_value => valid_attributes
        assigns(:statistic_value).should be_a(StatisticValue)
        assigns(:statistic_value).should be_persisted
      end

      it "redirects to the created statistic_value" do
        post :create, :statistic_value => valid_attributes
        response.should redirect_to(StatisticValue.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved statistic_value as @statistic_value" do
        # Trigger the behavior that occurs when invalid params are submitted
        StatisticValue.any_instance.stub(:save).and_return(false)
        post :create, :statistic_value => {}
        assigns(:statistic_value).should be_a_new(StatisticValue)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        StatisticValue.any_instance.stub(:save).and_return(false)
        post :create, :statistic_value => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested statistic_value" do
        statistic_value = StatisticValue.create! valid_attributes
        # Assuming there are no other statistic_values in the database, this
        # specifies that the StatisticValue created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        StatisticValue.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => statistic_value.id, :statistic_value => {'these' => 'params'}
      end

      it "assigns the requested statistic_value as @statistic_value" do
        statistic_value = StatisticValue.create! valid_attributes
        put :update, :id => statistic_value.id, :statistic_value => valid_attributes
        assigns(:statistic_value).should eq(statistic_value)
      end

      it "redirects to the statistic_value" do
        statistic_value = StatisticValue.create! valid_attributes
        put :update, :id => statistic_value.id, :statistic_value => valid_attributes
        response.should redirect_to(statistic_value)
      end
    end

    describe "with invalid params" do
      it "assigns the statistic_value as @statistic_value" do
        statistic_value = StatisticValue.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        StatisticValue.any_instance.stub(:save).and_return(false)
        put :update, :id => statistic_value.id.to_s, :statistic_value => {}
        assigns(:statistic_value).should eq(statistic_value)
      end

      it "re-renders the 'edit' template" do
        statistic_value = StatisticValue.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        StatisticValue.any_instance.stub(:save).and_return(false)
        put :update, :id => statistic_value.id.to_s, :statistic_value => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested statistic_value" do
      statistic_value = StatisticValue.create! valid_attributes
      expect {
        delete :destroy, :id => statistic_value.id.to_s
      }.to change(StatisticValue, :count).by(-1)
    end

    it "redirects to the statistic_values list" do
      statistic_value = StatisticValue.create! valid_attributes
      delete :destroy, :id => statistic_value.id.to_s
      response.should redirect_to(statistic_values_url)
    end
  end

end
