/*******************************************************************************
 * [y] hybris Platform
 *  
 *   Copyright (c) 2000-2014 hybris AG
 *   All rights reserved.
 *  
 *   This software is the confidential and proprietary information of hybris
 *   ("Confidential Information"). You shall not disclose such Confidential
 *   Information and shall use it only in accordance with the terms of the
 *   license agreement you entered into with hybris.
 ******************************************************************************/
package com.hybris.mobile.lib.b2b.test;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

import android.test.AndroidTestCase;

import com.hybris.mobile.lib.b2b.data.Category;
import com.hybris.mobile.lib.b2b.data.DataError;
import com.hybris.mobile.lib.b2b.data.DeliveryMode;
import com.hybris.mobile.lib.b2b.data.UserInformation;
import com.hybris.mobile.lib.b2b.data.cart.Cart;
import com.hybris.mobile.lib.b2b.data.cart.ProductAdded;
import com.hybris.mobile.lib.b2b.data.costcenter.CostCenter;
import com.hybris.mobile.lib.b2b.data.order.Order;
import com.hybris.mobile.lib.b2b.data.product.Product;
import com.hybris.mobile.lib.b2b.data.product.ProductList;
import com.hybris.mobile.lib.b2b.query.QueryCart;
import com.hybris.mobile.lib.b2b.query.QueryFacet;
import com.hybris.mobile.lib.b2b.query.QueryLogin;
import com.hybris.mobile.lib.b2b.query.QueryPlaceOrder;
import com.hybris.mobile.lib.b2b.query.QueryProductDetails;
import com.hybris.mobile.lib.b2b.query.QueryProducts;
import com.hybris.mobile.lib.b2b.response.ResponseReceiver;
import com.hybris.mobile.lib.b2b.service.ContentServiceHelper;
import com.hybris.mobile.lib.b2b.service.OCCServiceHelper;
import com.hybris.mobile.lib.b2b.utils.JsonUtils;
import com.hybris.mobile.lib.http.converter.DataConverter;
import com.hybris.mobile.lib.http.converter.JsonDataConverter;
import com.hybris.mobile.lib.http.manager.volley.VolleyPersistenceManager;
import com.hybris.mobile.lib.http.response.Response;


public class ContentServiceHelperTests extends AndroidTestCase
{
	private CountDownLatch lock = new CountDownLatch(1);
	private static final int NB_SECONDS_TO_WAIT_ASYNC_FINISH = 120;
	private ContentServiceHelper contentServiceHelper;
	private DataConverter dataConverter;
	private static final String USER = "anthony.lombardi@rustic-hw.com";
	private static final String PASSWORD = "12341234";
	private static final String PRODUCT_CODE = "3921095";


	@Override
	protected void setUp() throws Exception
	{
		super.setUp();
		dataConverter = new JsonDataConverter()
		{

			@Override
			public <T> Type getAssociatedTypeFromClass(Class<T> className)
			{
				return JsonUtils.getAssociatedTypeFromClass(className);
			}

			@Override
			public String createErrorMessage(String errorMessage)
			{
				return JsonUtils.createErrorMessage(errorMessage);
			}
		};
		contentServiceHelper = new OCCServiceHelper(getContext(), new VolleyPersistenceManager(getContext()), dataConverter);
	}

	public void testLogin() throws InterruptedException
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{
				lock.countDown();
			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();
			}

		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testGetProducts() throws InterruptedException
	{
		QueryProducts queryProducts = new QueryProducts();
		queryProducts.setCurrentPage(0);
		queryProducts.setPageSize(20);
		queryProducts.setQueryFacets(new ArrayList<QueryFacet>());

		contentServiceHelper.getProducts(new ResponseReceiver<ProductList>()
		{

			@Override
			public void onResponse(Response<ProductList> response)
			{
				lock.countDown();
			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();
			}
		}, "test", queryProducts, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testSearchProducts() throws InterruptedException
	{
		QueryProducts queryProducts = new QueryProducts();
		queryProducts.setSearchText("wire");
		queryProducts.setCurrentPage(0);
		queryProducts.setPageSize(20);
		queryProducts.setQueryFacets(new ArrayList<QueryFacet>());

		contentServiceHelper.getProducts(new ResponseReceiver<ProductList>()
		{

			@Override
			public void onResponse(Response<ProductList> response)
			{

				lock.countDown();
			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();
			}
		}, "test", queryProducts, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testGetProductDetails() throws InterruptedException
	{
		QueryProductDetails queryProductDetails = new QueryProductDetails();
		queryProductDetails.setCode(PRODUCT_CODE);

		contentServiceHelper.getProductDetails(new ResponseReceiver<Product>()
		{

			@Override
			public void onResponse(Response<Product> response)
			{

				lock.countDown();
			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryProductDetails, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testgetCatalog() throws InterruptedException
	{
		contentServiceHelper.getCatalog(new ResponseReceiver<List<Category>>()
		{

			@Override
			public void onResponse(Response<List<Category>> response)
			{

				lock.countDown();
			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}


	public void testIllegalArgumentException() throws InterruptedException
	{

		try
		{
			contentServiceHelper.login(new ResponseReceiver<UserInformation>()
			{

				@Override
				public void onResponse(Response<UserInformation> response)
				{
				}

				@Override
				public void onError(Response<DataError> response)
				{
					fail(response.getData().getErrorMessage().getMessage());
					lock.countDown();

				}
			}, "test", null, false, null, null);
		}
		catch (IllegalArgumentException e)
		{
			lock.countDown();
			assertTrue(true);
		}

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);

		try
		{
			contentServiceHelper.getProducts(new ResponseReceiver<ProductList>()
			{

				@Override
				public void onResponse(Response<ProductList> response)
				{
				}

				@Override
				public void onError(Response<DataError> response)
				{
					fail(response.getData().getErrorMessage().getMessage());
					lock.countDown();

				}
			}, "test", null, false, null, null);
		}
		catch (IllegalArgumentException e)
		{
			lock.countDown();
			assertTrue(true);
		}

		try
		{
			contentServiceHelper.getProductDetails(new ResponseReceiver<Product>()
			{

				@Override
				public void onResponse(Response<Product> response)
				{
				}

				@Override
				public void onError(Response<DataError> response)
				{
					fail(response.getData().getErrorMessage().getMessage());
					lock.countDown();

				}
			}, "test", null, false, null, null);
		}
		catch (IllegalArgumentException e)
		{
			lock.countDown();
			assertTrue(true);
		}

		try
		{
			contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
			{

				@Override
				public void onResponse(Response<ProductAdded> response)
				{
				}

				@Override
				public void onError(Response<DataError> response)
				{
					fail(response.getData().getErrorMessage().getMessage());
					lock.countDown();

				}
			}, "test", null, false, null, null);
		}
		catch (IllegalArgumentException e)
		{
			lock.countDown();
			assertTrue(true);
		}

		try
		{
			contentServiceHelper.updateCartEntry(new ResponseReceiver<ProductAdded>()
			{

				@Override
				public void onResponse(Response<ProductAdded> response)
				{
				}

				@Override
				public void onError(Response<DataError> response)
				{
					fail(response.getData().getErrorMessage().getMessage());
					lock.countDown();

				}
			}, "test", null, false, null, null);
		}
		catch (IllegalArgumentException e)
		{
			lock.countDown();
			assertTrue(true);
		}

		try
		{
			contentServiceHelper.deleteCartEntry(new ResponseReceiver<ProductAdded>()
			{

				@Override
				public void onResponse(Response<ProductAdded> response)
				{
				}

				@Override
				public void onError(Response<DataError> response)
				{
					fail(response.getData().getErrorMessage().getMessage());
					lock.countDown();

				}
			}, "test", null, false, null, null);
		}
		catch (IllegalArgumentException e)
		{
			lock.countDown();
			assertTrue(true);
		}

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testAddToCart() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{

			@Override
			public void onResponse(Response<UserInformation> response)
			{
				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{
					@Override
					public void onResponse(Response<ProductAdded> response)
					{

						lock.countDown();
					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, "test", queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}

		}, null, queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);

	}

	public void testUpdateCartEntry() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{

			@Override
			public void onResponse(Response<UserInformation> response)
			{



				final QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{
					@Override
					public void onResponse(Response<ProductAdded> response)
					{


						queryCart.setProduct("0");

						contentServiceHelper.updateCartEntry(new ResponseReceiver<ProductAdded>()
						{
							@Override
							public void onResponse(Response<ProductAdded> response)
							{

								lock.countDown();
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, "test", queryCart, false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, "test", queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}

		}, null, queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);

	}

	public void testDeleteCartEntry() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{

			@Override
			public void onResponse(Response<UserInformation> response)
			{



				final QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{
					@Override
					public void onResponse(Response<ProductAdded> response)
					{


						QueryCart queryCartDelete = new QueryCart();
						queryCartDelete.setProduct("0");

						contentServiceHelper.deleteCartEntry(new ResponseReceiver<ProductAdded>()
						{
							@Override
							public void onResponse(Response<ProductAdded> response)
							{

								lock.countDown();
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, "test", queryCartDelete, false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, "test", queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}

		}, null, queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);

	}

	public void testCreateCart() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{

			@Override
			public void onResponse(Response<UserInformation> response)
			{

				contentServiceHelper.createCart(new ResponseReceiver<Cart>()
				{
					@Override
					public void onResponse(Response<Cart> response)
					{

						lock.countDown();
					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, "test", false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, null, queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testGetCart() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{

			@Override
			public void onResponse(Response<UserInformation> response)
			{


				contentServiceHelper.getCart(new ResponseReceiver<Cart>()
				{
					@Override
					public void onResponse(Response<Cart> response)
					{

						lock.countDown();
					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}

		}, null, queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testGetCostCenters() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{



				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{


						contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
						{
							@Override
							public void onResponse(Response<List<CostCenter>> response)
							{

								lock.countDown();
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, "test", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testUpdateCostCenter() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{



				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{


						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{

								contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
								{
									@Override
									public void onResponse(Response<List<CostCenter>> response)
									{


										contentServiceHelper.updateCartCostCenter(new ResponseReceiver<Cart>()
										{

											@Override
											public void onResponse(Response<Cart> response)
											{

												lock.countDown();
											}

											@Override
											public void onError(Response<DataError> response)
											{
												fail(response.getData().getErrorMessage().getMessage());
												lock.countDown();

											}
										}, null, response.getData().get(0).getCode(), false, null, null);
									}

									@Override
									public void onError(Response<DataError> response)
									{
										fail(response.getData().getErrorMessage().getMessage());
										lock.countDown();

									}
								}, "test", false, null, null);
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testUpdateCartDeliveryAddress() throws InterruptedException
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{
				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{
						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{

								contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
								{
									@Override
									public void onResponse(Response<List<CostCenter>> response)
									{

										final CostCenter costCenter = response.getData().get(0);

										contentServiceHelper.updateCartCostCenter(new ResponseReceiver<Cart>()
										{

											@Override
											public void onResponse(Response<Cart> response)
											{

												contentServiceHelper.updateCartDeliveryAddress(new ResponseReceiver<Cart>()
												{
													@Override
													public void onResponse(Response<Cart> response)
													{
														lock.countDown();
													}

													@Override
													public void onError(Response<DataError> response)
													{
														fail(response.getData().getErrorMessage().getMessage());
														lock.countDown();

													}
												}, null, costCenter.getUnit().getAddresses().get(0).getId(), false, null, null);

											}

											@Override
											public void onError(Response<DataError> response)
											{
												fail(response.getData().getErrorMessage().getMessage());
												lock.countDown();

											}
										}, null, costCenter.getCode(), false, null, null);
									}

									@Override
									public void onError(Response<DataError> response)
									{
										fail(response.getData().getErrorMessage().getMessage());
										lock.countDown();

									}
								}, "test", false, null, null);
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);

	}

	public void testGetDeliveryModes() throws InterruptedException
	{

		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{

				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{

						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{

								contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
								{
									@Override
									public void onResponse(Response<List<CostCenter>> response)
									{

										final CostCenter costCenter = response.getData().get(0);

										contentServiceHelper.updateCartCostCenter(new ResponseReceiver<Cart>()
										{

											@Override
											public void onResponse(Response<Cart> response)
											{

												contentServiceHelper.updateCartDeliveryAddress(new ResponseReceiver<Cart>()
												{
													@Override
													public void onResponse(Response<Cart> response)
													{


														contentServiceHelper.getDeliveryModes(new ResponseReceiver<List<DeliveryMode>>()
														{

															@Override
															public void onResponse(Response<List<DeliveryMode>> response)
															{

																lock.countDown();
															}

															@Override
															public void onError(Response<DataError> response)
															{
																fail(response.getData().getErrorMessage().getMessage());
																lock.countDown();

															}
														}, null, false, null, null);

													}

													@Override
													public void onError(Response<DataError> response)
													{
														fail(response.getData().getErrorMessage().getMessage());
														lock.countDown();

													}
												}, null, costCenter.getUnit().getAddresses().get(0).getId(), false, null, null);

											}

											@Override
											public void onError(Response<DataError> response)
											{
												fail(response.getData().getErrorMessage().getMessage());
												lock.countDown();

											}
										}, null, costCenter.getCode(), false, null, null);
									}

									@Override
									public void onError(Response<DataError> response)
									{
										fail(response.getData().getErrorMessage().getMessage());
										lock.countDown();

									}
								}, "test", false, null, null);
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);
					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);


		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testUpdateDeliveryMode() throws InterruptedException
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{

				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{

						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{


								contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
								{

									@Override
									public void onResponse(Response<List<CostCenter>> response)
									{

										final CostCenter costCenter = response.getData().get(0);

										contentServiceHelper.updateCartCostCenter(new ResponseReceiver<Cart>()
										{

											@Override
											public void onResponse(Response<Cart> response)
											{

												contentServiceHelper.updateCartDeliveryAddress(new ResponseReceiver<Cart>()
												{
													@Override
													public void onResponse(Response<Cart> response)
													{


														contentServiceHelper.getDeliveryModes(new ResponseReceiver<List<DeliveryMode>>()
														{
															@Override
															public void onResponse(Response<List<DeliveryMode>> response)
															{



																DeliveryMode deliveryMode = response.getData().get(0);

																contentServiceHelper.updateCartDeliveryMode(new ResponseReceiver<Cart>()
																{
																	@Override
																	public void onResponse(Response<Cart> response)
																	{

																		lock.countDown();
																	}

																	@Override
																	public void onError(Response<DataError> response)
																	{
																		fail(response.getData().getErrorMessage().getMessage());
																		lock.countDown();

																	}
																}, "test", deliveryMode.getCode(), false, null, null);

															}

															@Override
															public void onError(Response<DataError> response)
															{
																fail(response.getData().getErrorMessage().getMessage());
																lock.countDown();

															}
														}, "test", false, null, null);

													}

													@Override
													public void onError(Response<DataError> response)
													{
														fail(response.getData().getErrorMessage().getMessage());
														lock.countDown();

													}
												}, null, costCenter.getUnit().getAddresses().get(0).getId(), false, null, null);
											}

											@Override
											public void onError(Response<DataError> response)
											{
												fail(response.getData().getErrorMessage().getMessage());
												lock.countDown();

											}
										}, null, costCenter.getCode(), false, null, null);

									}

									@Override
									public void onError(Response<DataError> response)
									{
										fail(response.getData().getErrorMessage().getMessage());
										lock.countDown();

									}
								}, null, false, null, null);

							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testUpdatePaymentTypeAccount() throws InterruptedException
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{

				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{

						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{

								lock.countDown();
							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testPlaceOrderWithAccount() throws InterruptedException
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{

				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{

						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{


								contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
								{

									@Override
									public void onResponse(Response<List<CostCenter>> response)
									{

										final CostCenter costCenter = response.getData().get(0);

										contentServiceHelper.updateCartCostCenter(new ResponseReceiver<Cart>()
										{

											@Override
											public void onResponse(Response<Cart> response)
											{

												contentServiceHelper.updateCartDeliveryAddress(new ResponseReceiver<Cart>()
												{
													@Override
													public void onResponse(Response<Cart> response)
													{


														contentServiceHelper.getDeliveryModes(new ResponseReceiver<List<DeliveryMode>>()
														{
															@Override
															public void onResponse(Response<List<DeliveryMode>> response)
															{



																DeliveryMode deliveryMode = response.getData().get(0);

																contentServiceHelper.updateCartDeliveryMode(new ResponseReceiver<Cart>()
																{
																	@Override
																	public void onResponse(Response<Cart> response)
																	{

																		QueryPlaceOrder queryPlaceOrder = new QueryPlaceOrder();
																		queryPlaceOrder.setTermsChecked(true);

																		contentServiceHelper.placeOrder(new ResponseReceiver<Order>()
																		{

																			@Override
																			public void onResponse(Response<Order> response)
																			{

																				lock.countDown();
																			}

																			@Override
																			public void onError(Response<DataError> response)
																			{
																				fail(response.getData().getErrorMessage().getMessage());
																				lock.countDown();

																			}
																		}, "test", queryPlaceOrder, false, null, null);

																	}

																	@Override
																	public void onError(Response<DataError> response)
																	{
																		fail(response.getData().getErrorMessage().getMessage());
																		lock.countDown();

																	}
																}, "test", deliveryMode.getCode(), false, null, null);

															}

															@Override
															public void onError(Response<DataError> response)
															{
																fail(response.getData().getErrorMessage().getMessage());
																lock.countDown();

															}
														}, "test", false, null, null);

													}

													@Override
													public void onError(Response<DataError> response)
													{
														fail(response.getData().getErrorMessage().getMessage());
														lock.countDown();

													}
												}, null, costCenter.getUnit().getAddresses().get(0).getId(), false, null, null);
											}

											@Override
											public void onError(Response<DataError> response)
											{
												fail(response.getData().getErrorMessage().getMessage());
												lock.countDown();

											}
										}, null, costCenter.getCode(), false, null, null);

									}

									@Override
									public void onError(Response<DataError> response)
									{
										fail(response.getData().getErrorMessage().getMessage());
										lock.countDown();

									}
								}, null, false, null, null);

							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	public void testGetOrderWithId() throws InterruptedException
	{
		QueryLogin queryLogin = new QueryLogin();
		queryLogin.setUsername(USER);
		queryLogin.setPassword(PASSWORD);

		contentServiceHelper.login(new ResponseReceiver<UserInformation>()
		{
			@Override
			public void onResponse(Response<UserInformation> response)
			{

				QueryCart queryCart = new QueryCart();
				queryCart.setProduct(PRODUCT_CODE);
				queryCart.setQuantity(5);
				contentServiceHelper.addProductToCart(new ResponseReceiver<ProductAdded>()
				{

					@Override
					public void onResponse(Response<ProductAdded> response)
					{

						contentServiceHelper.updateCartPaymentType(new ResponseReceiver<Cart>()
						{

							@Override
							public void onResponse(Response<Cart> response)
							{


								contentServiceHelper.getCostCenters(new ResponseReceiver<List<CostCenter>>()
								{

									@Override
									public void onResponse(Response<List<CostCenter>> response)
									{

										final CostCenter costCenter = response.getData().get(0);

										contentServiceHelper.updateCartCostCenter(new ResponseReceiver<Cart>()
										{

											@Override
											public void onResponse(Response<Cart> response)
											{

												contentServiceHelper.updateCartDeliveryAddress(new ResponseReceiver<Cart>()
												{
													@Override
													public void onResponse(Response<Cart> response)
													{


														contentServiceHelper.getDeliveryModes(new ResponseReceiver<List<DeliveryMode>>()
														{
															@Override
															public void onResponse(Response<List<DeliveryMode>> response)
															{



																DeliveryMode deliveryMode = response.getData().get(0);

																contentServiceHelper.updateCartDeliveryMode(new ResponseReceiver<Cart>()
																{
																	@Override
																	public void onResponse(Response<Cart> response)
																	{

																		QueryPlaceOrder queryPlaceOrder = new QueryPlaceOrder();
																		queryPlaceOrder.setTermsChecked(true);

																		contentServiceHelper.placeOrder(new ResponseReceiver<Order>()
																		{

																			@Override
																			public void onResponse(Response<Order> response)
																			{

																				Order order = response.getData();

																				contentServiceHelper.getOrder(new ResponseReceiver<Order>()
																				{
																					@Override
																					public void onResponse(Response<Order> response)
																					{
																						lock.countDown();
																					}

																					@Override
																					public void onError(Response<DataError> response)
																					{
																						fail(response.getData().getErrorMessage().getMessage());
																						lock.countDown();

																					}
																				}, "test", order.getCode(), false, null, null);
																				lock.countDown();
																			}

																			@Override
																			public void onError(Response<DataError> response)
																			{
																				fail(response.getData().getErrorMessage().getMessage());
																				lock.countDown();

																			}
																		}, "test", queryPlaceOrder, false, null, null);

																	}

																	@Override
																	public void onError(Response<DataError> response)
																	{
																		fail(response.getData().getErrorMessage().getMessage());
																		lock.countDown();

																	}
																}, "test", deliveryMode.getCode(), false, null, null);

															}

															@Override
															public void onError(Response<DataError> response)
															{
																fail(response.getData().getErrorMessage().getMessage());
																lock.countDown();

															}
														}, "test", false, null, null);

													}

													@Override
													public void onError(Response<DataError> response)
													{
														fail(response.getData().getErrorMessage().getMessage());
														lock.countDown();

													}
												}, null, costCenter.getUnit().getAddresses().get(0).getId(), false, null, null);
											}

											@Override
											public void onError(Response<DataError> response)
											{
												fail(response.getData().getErrorMessage().getMessage());
												lock.countDown();

											}
										}, null, costCenter.getCode(), false, null, null);

									}

									@Override
									public void onError(Response<DataError> response)
									{
										fail(response.getData().getErrorMessage().getMessage());
										lock.countDown();

									}
								}, null, false, null, null);

							}

							@Override
							public void onError(Response<DataError> response)
							{
								fail(response.getData().getErrorMessage().getMessage());
								lock.countDown();

							}
						}, null, "ACCOUNT", false, null, null);

					}

					@Override
					public void onError(Response<DataError> response)
					{
						fail(response.getData().getErrorMessage().getMessage());
						lock.countDown();

					}
				}, null, queryCart, false, null, null);

			}

			@Override
			public void onError(Response<DataError> response)
			{
				fail(response.getData().getErrorMessage().getMessage());
				lock.countDown();

			}
		}, "test", queryLogin, false, null, null);

		lock.await(NB_SECONDS_TO_WAIT_ASYNC_FINISH, TimeUnit.SECONDS);
	}

	@Override
	protected void tearDown() throws Exception
	{
		super.tearDown();
		contentServiceHelper = null;
		dataConverter = null;
	}
}
