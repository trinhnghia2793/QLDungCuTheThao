using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Nhom3_QuanLyDungCuTheThao.Models;

namespace Nhom3_QuanLyDungCuTheThao.Controllers
{
    public class PurchaseController : Controller
    {
        //
        // GET: /Purchase/

        public ActionResult Index(int id = 0)
        {
            if (Session["currentUser"] != null)
            {
                using (var dbContext = new SHSDBDataContext())
                {
                    List<user_order> orders = dbContext.user_orders.Where(uo => uo.user_account_id == (Session["currentUser"] as user_account).user_account_id).OrderByDescending(uo => uo.order_time).ToList();
                    if (id != 0)
                    {
                        TempData["id"] = id;
                        TempData["details"] = 1;
                        return RedirectToAction("Index", "Purchase", new { id = 0, orders });
                    }
                    return View(orders);
                }
            }
            return RedirectToAction("Index", "Home");
        }
        public ActionResult UserOrderProcessConfirm(int id)
        {
            using (var dbContext = new SHSDBDataContext())
            {
                user_order processOrder = dbContext.user_orders.SingleOrDefault(uo => uo.user_order_id == id);
                processOrder.is_delivered = true;
                dbContext.SubmitChanges();
                if (processOrder.user_account_id != null)
                {
                    user_account user = dbContext.user_accounts.SingleOrDefault(ua => ua.user_account_id == processOrder.user_account_id);
                    int bonus_point = (int)processOrder.order_total_value / 2000;
                    user.user_point+= bonus_point;
                    if (user.user_point >= 2000)
                    {
                        user.user_member_tier = UserRanking.DIAMOND;
                    }
                    else if (user.user_point >= 750)
                    {
                        user.user_member_tier = UserRanking.PLATINUM;
                    }
                    else if (user.user_point >= 250)
                    {
                        user.user_member_tier = UserRanking.GOLD;
                    }
                    else if (user.user_point >= 100)
                    {
                        user.user_member_tier = UserRanking.SILVER;
                    }
                    else
                    {
                        user.user_member_tier = UserRanking.BRONZE;
                    }
                    dbContext.SubmitChanges();
                }
                List<user_order> orders = dbContext.user_orders.Where(uo => uo.is_processed == false).OrderByDescending(uo => uo.order_time).ToList();
                return RedirectToAction("Index", "Purchase", new { id = 0, orders });
            }
        }
        public ActionResult Details()
        {
            using (var dbContext = new SHSDBDataContext())
            {
                int id = (int)TempData["id"];
                List<user_order_product> order_products = dbContext.user_order_products.Where(op => op.user_order_id == id).ToList();
                return PartialView(order_products);
            }
        }

        public ActionResult ConfirmCancel()
        {
            return PartialView();
        }

        public ActionResult CancelOrder(int id)
        {
            using (var dbContext = new SHSDBDataContext())
            {
                user_order deleteOrder = dbContext.user_orders.SingleOrDefault(uo => uo.user_order_id == id);
                List<user_order_product> refDeleteOrder = dbContext.user_order_products.Where(op => op.user_order_id == deleteOrder.user_order_id).ToList();
                foreach (user_order_product refProduct in refDeleteOrder)
                {
                    product prd = dbContext.products.SingleOrDefault(p => p.product_id == refProduct.product_id);
                    prd.product_inventory += refProduct.order_product_amount;
                    dbContext.SubmitChanges();
                }
                dbContext.user_order_products.DeleteAllOnSubmit(refDeleteOrder);
                dbContext.SubmitChanges();
                dbContext.user_orders.DeleteOnSubmit(deleteOrder);
                dbContext.SubmitChanges();
            }
            return RedirectToAction("Index", "Purchase");
        }

    }
}
